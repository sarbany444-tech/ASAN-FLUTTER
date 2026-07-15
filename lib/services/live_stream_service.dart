import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';

/// Live streaming architecture — integrates with WebRTC/RTMP backend in production.
class LiveStreamService {
  LiveStreamService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<LiveStreamModel>> watchLiveStreams() {
    return _firestore
        .collection(AppConstants.liveStreamsCollection)
        .where('status', isEqualTo: 'live')
        .orderBy('viewerCount', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LiveStreamModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<String> startLiveStream({
    required String hostId,
    required String hostName,
    required String title,
    required String category,
  }) async {
    final ref = _firestore.collection(AppConstants.liveStreamsCollection).doc();
    await ref.set({
      'hostId': hostId,
      'hostName': hostName,
      'title': title,
      'category': category,
      'status': 'live',
      'viewerCount': 0,
      'streamUrl': 'rtmp://live.naseem.app/$hostId/${ref.id}',
      'startedAt': FieldValue.serverTimestamp(),
      'moderationEnabled': true,
    });
    return ref.id;
  }

  Future<void> endLiveStream(String streamId) async {
    await _firestore
        .collection(AppConstants.liveStreamsCollection)
        .doc(streamId)
        .update({'status': 'ended', 'endedAt': FieldValue.serverTimestamp()});
  }

  Future<void> sendLiveComment({
    required String streamId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    await _firestore
        .collection(AppConstants.liveStreamsCollection)
        .doc(streamId)
        .collection('live_comments')
        .add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendLiveReaction({
    required String streamId,
    required String userId,
    required String reaction,
  }) async {
    await _firestore
        .collection(AppConstants.liveStreamsCollection)
        .doc(streamId)
        .collection('live_reactions')
        .add({
      'userId': userId,
      'reaction': reaction,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchLiveComments(String streamId) {
    return _firestore
        .collection(AppConstants.liveStreamsCollection)
        .doc(streamId)
        .collection('live_comments')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
