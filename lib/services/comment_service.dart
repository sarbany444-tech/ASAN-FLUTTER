import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';

class CommentService {
  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<CommentModel>> watchComments(String videoId) {
    return _firestore
        .collection(AppConstants.commentsCollection)
        .where('videoId', isEqualTo: videoId)
        .where('parentCommentId', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommentModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<CommentModel>> watchReplies(String parentCommentId) {
    return _firestore
        .collection(AppConstants.commentsCollection)
        .where('parentCommentId', isEqualTo: parentCommentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommentModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<String> addComment({
    required String videoId,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String text,
    String? parentCommentId,
    List<String> mentions = const [],
  }) async {
    final ref = _firestore.collection(AppConstants.commentsCollection).doc();
    await ref.set({
      ...CommentModel(
        id: ref.id,
        videoId: videoId,
        userId: userId,
        userDisplayName: userDisplayName,
        text: text,
        userPhotoUrl: userPhotoUrl,
        parentCommentId: parentCommentId,
        mentions: mentions,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'commentCount': FieldValue.increment(1)});

    if (parentCommentId != null) {
      await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(parentCommentId)
          .update({'replyCount': FieldValue.increment(1)});
    }

    return ref.id;
  }

  Future<void> toggleCommentLike(String commentId, String userId) async {
    final ref = _firestore.collection(AppConstants.commentsCollection).doc(commentId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final likedBy = List<String>.from(snap.data()!['likedBy'] as List? ?? []);
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        tx.update(ref, {'likedBy': likedBy, 'likeCount': FieldValue.increment(-1)});
      } else {
        likedBy.add(userId);
        tx.update(ref, {'likedBy': likedBy, 'likeCount': FieldValue.increment(1)});
      }
    });
  }

  Future<void> deleteComment(String commentId, String videoId) async {
    await _firestore.collection(AppConstants.commentsCollection).doc(commentId).delete();
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'commentCount': FieldValue.increment(-1)});
  }
}
