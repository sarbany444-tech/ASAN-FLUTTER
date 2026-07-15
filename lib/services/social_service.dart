import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/video_model.dart';

class SocialService {
  SocialService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> toggleSave(String videoId, String userId) async {
    final videoRef =
        _firestore.collection(AppConstants.videosCollection).doc(videoId);
    final savedRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.savedVideosCollection)
        .doc(videoId);

    final savedDoc = await savedRef.get();
    if (savedDoc.exists) {
      await savedRef.delete();
      await videoRef.update({
        'saveCount': FieldValue.increment(-1),
        'savedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await savedRef.set({
        'videoId': videoId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      await videoRef.update({
        'saveCount': FieldValue.increment(1),
        'savedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<List<VideoModel>> getSavedVideos(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.savedVideosCollection)
        .orderBy('savedAt', descending: true)
        .get();

    final videos = <VideoModel>[];
    for (final doc in snapshot.docs) {
      final videoId = doc.data()['videoId'] as String? ?? doc.id;
      final videoDoc = await _firestore
          .collection(AppConstants.videosCollection)
          .doc(videoId)
          .get();
      if (videoDoc.exists) {
        videos.add(VideoModel.fromMap(videoDoc.data()!, videoDoc.id));
      }
    }
    return videos;
  }

  Future<List<VideoModel>> getWatchHistoryVideos(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.watchHistoryCollection)
        .orderBy('watchedAt', descending: true)
        .limit(50)
        .get();

    final videos = <VideoModel>[];
    for (final doc in snapshot.docs) {
      final videoId = doc.data()['videoId'] as String? ?? doc.id;
      final videoDoc = await _firestore
          .collection(AppConstants.videosCollection)
          .doc(videoId)
          .get();
      if (videoDoc.exists) {
        videos.add(VideoModel.fromMap(videoDoc.data()!, videoDoc.id));
      }
    }
    return videos;
  }
}
