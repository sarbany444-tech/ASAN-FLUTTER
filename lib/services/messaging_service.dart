import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';

class MessagingService {
  MessagingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _conversationId(String userA, String userB) {
    final sorted = [userA, userB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<ConversationModel>> watchConversations(String userId) {
    return _firestore
        .collection(AppConstants.conversationsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConversationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection(AppConstants.conversationsCollection)
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<String> sendMessage({
    required String senderId,
    required String recipientId,
    required String text,
  }) async {
    final convId = _conversationId(senderId, recipientId);
    final convRef =
        _firestore.collection(AppConstants.conversationsCollection).doc(convId);

    final msgRef = convRef.collection(AppConstants.messagesCollection).doc();

    await _firestore.runTransaction((tx) async {
      tx.set(convRef, {
        'participantIds': [senderId, recipientId],
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(msgRef, {
        ...MessageModel(
          id: msgRef.id,
          conversationId: convId,
          senderId: senderId,
          text: text,
        ).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return msgRef.id;
  }

  Future<void> markMessagesRead(String conversationId, String userId) async {
    final snap = await _firestore
        .collection(AppConstants.conversationsCollection)
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
