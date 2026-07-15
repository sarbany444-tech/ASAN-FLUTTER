import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../data/dev_video_store.dart';
import '../data/mock_feed_videos.dart';
import '../models/enums.dart';
import '../models/video_model.dart';
import 'recommendation_service.dart';
import '../models/social_models.dart';

class FeedService {
  FeedService({
    FirebaseFirestore? firestore,
    RecommendationService? recommendation,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _recommendation = recommendation ?? RecommendationService();

  final FirebaseFirestore _firestore;
  final RecommendationService _recommendation;

  DocumentSnapshot? _lastForYouDoc;
  DocumentSnapshot? _lastFollowingDoc;
  bool _hasMoreForYou = true;
  bool _hasMoreFollowing = true;

  bool get hasMoreForYou => _hasMoreForYou;
  bool get hasMoreFollowing => _hasMoreFollowing;

  void resetPagination() {
    _lastForYouDoc = null;
    _lastFollowingDoc = null;
    _hasMoreForYou = true;
    _hasMoreFollowing = true;
  }

  Future<List<VideoModel>> fetchForYouPage({
    List<WatchHistoryEntry> watchHistory = const [],
    List<String> followingIds = const [],
  }) async {
    if (AppConstants.bypassAuthForDevelopment) {
      _hasMoreForYou = false;
      return [
        ...DevVideoStore.instance.videos,
        ...MockFeedVideos.sampleVideos,
      ];
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.videosCollection)
          .where('status', isEqualTo: VideoStatus.approved.value)
          .where('privacy', isEqualTo: VideoPrivacy.public.value)
          .orderBy('engagementScore', descending: true)
          .limit(AppConstants.feedPageSize);

      if (_lastForYouDoc != null) {
        query = query.startAfterDocument(_lastForYouDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasMoreForYou = false;
        return MockFeedVideos.sampleVideos;
      }

      _lastForYouDoc = snapshot.docs.last;
      if (snapshot.docs.length < AppConstants.feedPageSize) {
        _hasMoreForYou = false;
      }

      final videos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();

      final prefs = _recommendation.buildCategoryPreferences(watchHistory);
      return _recommendation.rankForYou(
        videos: videos,
        watchHistory: watchHistory,
        followingIds: followingIds,
        categoryPreferences: prefs,
      );
    } catch (_) {
      _hasMoreForYou = false;
      return MockFeedVideos.sampleVideos;
    }
  }

  Future<List<VideoModel>> fetchFollowingPage(List<String> followingIds) async {
    if (AppConstants.bypassAuthForDevelopment) {
      _hasMoreFollowing = false;
      return [
        ...DevVideoStore.instance.videos.take(3),
        ...MockFeedVideos.sampleVideos.take(3),
      ];
    }

    if (followingIds.isEmpty) return [];

    try {
      // Firestore 'in' queries limited to 30 items
      final batch = followingIds.take(30).toList();

      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.videosCollection)
          .where('status', isEqualTo: VideoStatus.approved.value)
          .where('userId', whereIn: batch)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.feedPageSize);

      if (_lastFollowingDoc != null) {
        query = query.startAfterDocument(_lastFollowingDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasMoreFollowing = false;
        return [];
      }

      _lastFollowingDoc = snapshot.docs.last;
      if (snapshot.docs.length < AppConstants.feedPageSize) {
        _hasMoreFollowing = false;
      }

      return snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      _hasMoreFollowing = false;
      return MockFeedVideos.sampleVideos.take(3).toList();
    }
  }

  Future<List<VideoModel>> fetchTrending({int limit = 20}) async {
    if (AppConstants.bypassAuthForDevelopment) {
      final videos = [
        ...DevVideoStore.instance.videos,
        ...MockFeedVideos.sampleVideos,
      ];
      return _recommendation.rankTrending(videos.take(limit).toList());
    }

    try {
      final snapshot = await _firestore
          .collection(AppConstants.videosCollection)
          .where('status', isEqualTo: VideoStatus.approved.value)
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return _recommendation.rankTrending(MockFeedVideos.sampleVideos);
      }

      final videos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();

      return _recommendation.rankTrending(videos);
    } catch (_) {
      return _recommendation.rankTrending(MockFeedVideos.sampleVideos);
    }
  }

  Future<void> recordWatch({
    required String userId,
    required String videoId,
    required String category,
    int durationSeconds = 0,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.watchHistoryCollection)
        .doc(videoId)
        .set({
      'videoId': videoId,
      'category': category,
      'watchDurationSeconds': durationSeconds,
      'watchedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<WatchHistoryEntry>> getWatchHistory(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.watchHistoryCollection)
        .orderBy('watchedAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return WatchHistoryEntry(
        videoId: data['videoId'] as String? ?? doc.id,
        userId: userId,
        watchedAt: data['watchedAt']?.toDate() as DateTime?,
        watchDurationSeconds: data['watchDurationSeconds'] as int? ?? 0,
        category: data['category'] as String?,
      );
    }).toList();
  }
}
