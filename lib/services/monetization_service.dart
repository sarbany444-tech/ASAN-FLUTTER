import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Monetization architecture — donations, subscriptions, courses.
class MonetizationService {
  MonetizationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> recordDonation({
    required String donorId,
    required String creatorId,
    required double amount,
    required String type,
    String? message,
  }) async {
    await _firestore.collection(AppConstants.donationsCollection).add({
      'donorId': donorId,
      'creatorId': creatorId,
      'amount': amount,
      'type': type,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> subscribe({
    required String subscriberId,
    required String creatorId,
    required String tier,
  }) async {
    await _firestore
        .collection(AppConstants.subscriptionsCollection)
        .doc('${subscriberId}_$creatorId')
        .set({
      'subscriberId': subscriberId,
      'creatorId': creatorId,
      'tier': tier,
      'status': 'active',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isSubscribed(String subscriberId, String creatorId) async {
    final doc = await _firestore
        .collection(AppConstants.subscriptionsCollection)
        .doc('${subscriberId}_$creatorId')
        .get();
    return doc.exists && doc.data()?['status'] == 'active';
  }

  Future<List<Map<String, dynamic>>> getCourses({String? category}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.coursesCollection)
        .where('isPublished', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snap = await query.limit(20).get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<double> getCreatorRewardsBalance(String creatorId) async {
    final snap = await _firestore
        .collection(AppConstants.donationsCollection)
        .where('creatorId', isEqualTo: creatorId)
        .where('status', isEqualTo: 'completed')
        .get();

    return snap.docs.fold<double>(
      0,
      (total, doc) => total + ((doc.data()['amount'] as num?)?.toDouble() ?? 0),
    );
  }
}
