import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class FollowService {
  FollowService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> follow({
    required String followerId,
    required String followingId,
    required String followerName,
  }) async {
    final followRef = _firestore
        .collection(AppConstants.followsCollection)
        .doc('${followerId}_$followingId');
    final followerRef =
        _firestore.collection(AppConstants.usersCollection).doc(followerId);
    final followingRef =
        _firestore.collection(AppConstants.usersCollection).doc(followingId);

    await followRef.set({
      'followerId': followerId,
      'followingId': followingId,
      'followerName': followerName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await followerRef.update({
      'followingCount': FieldValue.increment(1),
      'followingIds': FieldValue.arrayUnion([followingId]),
    });
    await followingRef.update({
      'followerCount': FieldValue.increment(1),
    });
  }

  Future<void> unfollow({
    required String followerId,
    required String followingId,
  }) async {
    final followRef = _firestore
        .collection(AppConstants.followsCollection)
        .doc('${followerId}_$followingId');
    final followerRef =
        _firestore.collection(AppConstants.usersCollection).doc(followerId);
    final followingRef =
        _firestore.collection(AppConstants.usersCollection).doc(followingId);

    await followRef.delete();
    await followerRef.update({
      'followingCount': FieldValue.increment(-1),
      'followingIds': FieldValue.arrayRemove([followingId]),
    });
    await followingRef.update({
      'followerCount': FieldValue.increment(-1),
    });
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    final doc = await _firestore
        .collection(AppConstants.followsCollection)
        .doc('${followerId}_$followingId')
        .get();
    return doc.exists;
  }

  Stream<List<UserModel>> watchFollowers(String userId) {
    return _firestore
        .collection(AppConstants.followsCollection)
        .where('followingId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = <UserModel>[];
      for (final doc in snapshot.docs) {
        final followerId = doc.data()['followerId'] as String? ?? '';
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(followerId)
            .get();
        if (userDoc.exists) {
          users.add(UserModel.fromMap(userDoc.data()!, userDoc.id));
        }
      }
      return users;
    });
  }

  Stream<List<UserModel>> watchFollowing(String userId) {
    return _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = <UserModel>[];
      for (final doc in snapshot.docs) {
        final followingId = doc.data()['followingId'] as String? ?? '';
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(followingId)
            .get();
        if (userDoc.exists) {
          users.add(UserModel.fromMap(userDoc.data()!, userDoc.id));
        }
      }
      return users;
    });
  }
}
