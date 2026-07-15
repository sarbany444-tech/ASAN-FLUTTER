import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/web_video_blob.dart';
import '../data/dev_video_store.dart';
import '../models/enums.dart';
import '../models/video_model.dart';
import 'moderation_service.dart';

class VideoService {
  VideoService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ModerationService? moderationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _moderation = moderationService ?? ModerationService();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ModerationService _moderation;
  final _uuid = const Uuid();

  Stream<List<VideoModel>> getApprovedFeed({String? category}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.videosCollection)
        .where('status', isEqualTo: VideoStatus.approved.value)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.feedPageSize);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<VideoModel>> getUserVideos(String userId) {
    return _firestore
        .collection(AppConstants.videosCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<VideoModel?> getVideo(String videoId) async {
    final doc = await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .get();
    if (!doc.exists) return null;
    return VideoModel.fromMap(doc.data()!, doc.id);
  }

  Future<String> uploadVideo({
    Uint8List? videoBytes,
    XFile? videoFile,
    String? webPreviewUrl,
    required String fileName,
    String mimeType = 'video/mp4',
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String title,
    required String description,
    required String category,
    bool isUserVerified = false,
    List<String> hashtags = const [],
    List<String> mentions = const [],
    String privacy = 'public',
    String? captions,
    String? filterName,
    List<Map<String, dynamic>> textOverlays = const [],
  }) async {
    final bytes = videoBytes ?? await videoFile!.readAsBytes();
    final resolvedName =
        fileName.trim().isNotEmpty ? fileName.trim() : 'video.mp4';

    if (AppConstants.bypassAuthForDevelopment) {
      return _uploadVideoLocally(
        videoBytes: bytes,
        webPreviewUrl: webPreviewUrl,
        fileName: resolvedName,
        mimeType: mimeType,
        userId: userId,
        userDisplayName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        title: title,
        description: description,
        category: category,
        isUserVerified: isUserVerified,
        hashtags: hashtags,
        privacy: privacy,
        captions: captions,
        filterName: filterName,
        textOverlays: textOverlays,
      );
    }

    final videoId = _uuid.v4();
    final videoRef = _storage.ref(
      '${AppConstants.videoStoragePath}/$userId/$videoId.mp4',
    );

    await videoRef.putData(
      bytes,
      SettableMetadata(contentType: mimeType),
    );
    final videoUrl = await videoRef.getDownloadURL();

    final videoData = {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'status': VideoStatus.processing.value,
      'privacy': privacy,
      'hashtags': hashtags,
      'mentions': mentions,
      'captions': captions,
      'filterName': filterName,
      'textOverlays': textOverlays,
      'isUserVerified': isUserVerified,
      'likeCount': 0,
      'commentCount': 0,
      'shareCount': 0,
      'viewCount': 0,
      'saveCount': 0,
      'engagementScore': 0.0,
      'trendingScore': 0.0,
      'moderationScore': 0.0,
      'moderationFlags': <String>[],
      'likedBy': <String>[],
      'savedBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .set(videoData);

    // Trigger moderation pipeline
    final moderationResult = await _moderation.analyzeUpload(
      videoId: videoId,
      title: title,
      description: description,
      category: category,
    );

    final newStatus = moderationResult.isApproved
        ? VideoStatus.approved.value
        : moderationResult.isRejected
            ? VideoStatus.rejected.value
            : VideoStatus.pending.value;

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({
      'status': newStatus,
      'transcript': moderationResult.transcript,
      'moderationScore': moderationResult.score,
      'moderationFlags': moderationResult.flags,
    });

    if (newStatus == VideoStatus.approved.value) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'videoCount': FieldValue.increment(1)});
    }

    if (moderationResult.needsReview) {
      await _firestore
          .collection(AppConstants.moderationQueueCollection)
          .doc(videoId)
          .set({
        'videoId': videoId,
        'userId': userId,
        'title': title,
        'status': 'pending_review',
        'moderationResult': moderationResult.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return videoId;
  }

  Future<String> _uploadVideoLocally({
    required Uint8List videoBytes,
    String? webPreviewUrl,
    required String fileName,
    String mimeType = 'video/mp4',
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String title,
    required String description,
    required String category,
    bool isUserVerified = false,
    List<String> hashtags = const [],
    String privacy = 'public',
    String? captions,
    String? filterName,
    List<Map<String, dynamic>> textOverlays = const [],
  }) async {
    final videoId = _uuid.v4();

    final videoUrl = kIsWeb
        ? (webPreviewUrl != null && webPreviewUrl.startsWith('blob:')
            ? webPreviewUrl
            : createWebBlobUrl(videoBytes, mimeType))
        : XFile.fromData(
            videoBytes,
            mimeType: mimeType,
            name: fileName,
          ).path;

    if (videoUrl.isEmpty) {
      throw StateError('Could not create a playable URL for the selected video.');
    }

    final video = VideoModel(
      id: videoId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPhotoUrl: userPhotoUrl,
      title: title,
      description: description,
      category: category,
      videoUrl: videoUrl,
      captions: captions,
      filterName: filterName,
      status: VideoStatus.approved,
      privacy: VideoPrivacy.fromString(privacy),
      engagementScore: 100,
      trendingScore: 100,
      isUserVerified: isUserVerified,
      hashtags: hashtags,
      textOverlays: textOverlays,
      createdAt: DateTime.now(),
    );

    DevVideoStore.instance.addVideo(video);
    return videoId;
  }

  Future<void> toggleLike(String videoId, String userId) async {
    final videoRef =
        _firestore.collection(AppConstants.videosCollection).doc(videoId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(videoRef);
      if (!snapshot.exists) return;

      final likedBy = List<String>.from(snapshot.data()!['likedBy'] as List? ?? []);
      final isLiked = likedBy.contains(userId);

      if (isLiked) {
        likedBy.remove(userId);
        transaction.update(videoRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(userId);
        transaction.update(videoRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> incrementViewCount(String videoId) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'viewCount': FieldValue.increment(1)});
  }

  Future<void> incrementShareCount(String videoId) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'shareCount': FieldValue.increment(1)});
  }

  Future<List<VideoModel>> searchVideos(String query) async {
    if (query.isEmpty) return [];

    final titleResults = await _firestore
        .collection(AppConstants.videosCollection)
        .where('status', isEqualTo: VideoStatus.approved.value)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .limit(20)
        .get();

    return titleResults.docs
        .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
