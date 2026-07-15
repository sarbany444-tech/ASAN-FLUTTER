import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../models/social_models.dart';

class DiscoveryService {
  DiscoveryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<VideoModel>> searchVideos(String query) async {
    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .where('status', isEqualTo: VideoStatus.approved.value)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .get();

    final lower = query.toLowerCase();
    return snapshot.docs
        .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
        .where((v) =>
            v.title.toLowerCase().contains(lower) ||
            v.description.toLowerCase().contains(lower) ||
            v.hashtags.any((tag) => tag.toLowerCase().contains(lower)))
        .toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .limit(50)
        .get();

    final lower = query.toLowerCase();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => u.displayName.toLowerCase().contains(lower))
        .toList();
  }

  Future<List<HashtagModel>> searchHashtags(String query) async {
    final snapshot = await _firestore
        .collection(AppConstants.hashtagsCollection)
        .limit(30)
        .get();

    final lower = query.toLowerCase();
    return snapshot.docs
        .map((doc) => HashtagModel.fromMap(doc.data(), doc.id))
        .where((h) => h.tag.toLowerCase().contains(lower))
        .toList();
  }

  Future<List<HashtagModel>> getTrendingHashtags() async {
    final snapshot = await _firestore
        .collection(AppConstants.hashtagsCollection)
        .orderBy('trendingScore', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => HashtagModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<UserModel>> getRecommendedCreators(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('followerCount', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => u.uid != userId)
        .toList();
  }

  Future<List<VideoModel>> getVideosByHashtag(String tag) async {
    final snapshot = await _firestore
        .collection(AppConstants.videosCollection)
        .where('status', isEqualTo: VideoStatus.approved.value)
        .where('hashtags', arrayContains: tag.toLowerCase())
        .orderBy('createdAt', descending: true)
        .limit(30)
        .get();
    return snapshot.docs
        .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> upsertHashtag(String tag, String category) async {
    final ref =
        _firestore.collection(AppConstants.hashtagsCollection).doc(tag);
    await ref.set({
      'tag': tag,
      'category': category,
      'videoCount': FieldValue.increment(1),
      'trendingScore': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> upsertHashtags(List<String> tags, {String category = 'general'}) async {
    for (final tag in tags) {
      await upsertHashtag(tag.toLowerCase(), category);
    }
  }
}
