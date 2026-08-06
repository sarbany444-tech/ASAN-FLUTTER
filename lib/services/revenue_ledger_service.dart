import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/monetization/monetization.dart';
import 'firebase_service.dart';

/// Modular revenue ledger — records intent/charges for every product type.
///
/// During launch, events are recorded with `status: deferred` / `amount: 0`
/// so analytics work before payment processors are connected.
class RevenueLedgerService {
  RevenueLedgerService({this._firestore});

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialized) return null;
    return _firestore ??= FirebaseFirestore.instance;
  }

  Future<String?> recordEvent({
    required RevenueProductType type,
    required String userId,
    required double amount,
    required String currency,
    String? categoryId,
    String? listingId,
    String? planId,
    String status = 'recorded',
    Map<String, dynamic>? metadata,
  }) async {
    final db = _db;
    if (db == null) return null;

    final ref = db.collection(AppConstants.revenueEventsCollection).doc();
    await ref.set({
      'type': type.value,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'categoryId': ?categoryId,
      'listingId': ?listingId,
      'planId': ?planId,
      'status': status,
      'metadata': ?metadata,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Convenience: log a Coming Soon plan view / interest without charging.
  Future<void> recordBusinessPlanInterest({
    required String userId,
    required String planId,
    String? categoryId,
  }) {
    return recordEvent(
      type: RevenueProductType.businessSubscription,
      userId: userId,
      amount: 0,
      currency: 'EUR',
      planId: planId,
      categoryId: categoryId,
      status: 'interest',
      metadata: {'comingSoon': true},
    ).then((_) {});
  }
}
