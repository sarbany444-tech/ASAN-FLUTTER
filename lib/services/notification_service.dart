import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? fromUserId,
    String? fromUserName,
    String? fromUserPhoto,
    String? videoId,
    String? commentId,
  }) async {
    if (fromUserId != null && fromUserId == userId) return;

    await _firestore.collection(AppConstants.notificationsCollection).add({
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhoto': fromUserPhoto,
      'videoId': videoId,
      'commentId': commentId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
