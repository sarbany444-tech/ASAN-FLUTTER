import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';
import '../models/enums.dart';

class CreatorAnalyticsService {
  CreatorAnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<CreatorAnalyticsModel> getAnalytics(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.creatorAnalyticsCollection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return CreatorAnalyticsModel.fromMap(doc.data()!, userId);
    }

    // Compute from videos if no analytics doc
    final videos = await _firestore
        .collection(AppConstants.videosCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: VideoStatus.approved.value)
        .get();

    var views = 0, likes = 0, comments = 0, shares = 0;
    final topVideos = <String, int>{};

    for (final doc in videos.docs) {
      final data = doc.data();
      views += data['viewCount'] as int? ?? 0;
      likes += data['likeCount'] as int? ?? 0;
      comments += data['commentCount'] as int? ?? 0;
      shares += data['shareCount'] as int? ?? 0;
      topVideos[doc.id] = data['viewCount'] as int? ?? 0;
    }

    final sortedTop = topVideos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final userDoc =
        await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
    final followers = userDoc.data()?['followerCount'] as int? ?? 0;

    return CreatorAnalyticsModel(
      userId: userId,
      totalViews: views,
      totalLikes: likes,
      totalComments: comments,
      totalShares: shares,
      totalFollowers: followers,
      topVideos: sortedTop.take(5).map((e) => e.key).toList(),
    );
  }

  Future<void> refreshAnalytics(String userId) async {
    final analytics = await getAnalytics(userId);
    await _firestore
        .collection(AppConstants.creatorAnalyticsCollection)
        .doc(userId)
        .set({
      'totalViews': analytics.totalViews,
      'totalLikes': analytics.totalLikes,
      'totalComments': analytics.totalComments,
      'totalShares': analytics.totalShares,
      'totalFollowers': analytics.totalFollowers,
      'topVideos': analytics.topVideos,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
