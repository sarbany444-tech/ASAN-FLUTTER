import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/monetization/monetization.dart';
import 'firebase_service.dart';

/// Tracks business interest, account type, and listing volume for growth
/// decisions — without charging anyone during launch.
class MarketplaceTrackingService {
  MarketplaceTrackingService({FirebaseFirestore? this._firestore});

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialized) return null;
    return _firestore ??= FirebaseFirestore.instance;
  }

  DocumentReference<Map<String, dynamic>>? _userDoc(String userId) {
    final db = _db;
    if (db == null) return null;
    return db.collection(AppConstants.usersCollection).doc(userId);
  }

  DocumentReference<Map<String, dynamic>>? get _statsDoc {
    final db = _db;
    if (db == null) return null;
    return db
        .collection(AppConstants.analyticsCollection)
        .doc(AppConstants.platformStatsDoc);
  }

  /// Mark / convert a user toward business (no payment at launch).
  Future<void> trackBusinessInterest({
    required String userId,
    required List<String> categoryIds,
    String source = 'business_plans_screen',
    bool convertToBusinessAccount = false,
  }) async {
    final userRef = _userDoc(userId);
    final db = _db;
    if (userRef == null || db == null) return;

    final batch = db.batch();
    batch.set(
      userRef,
      {
        'interestedInBusiness': true,
        'businessInterestAt': FieldValue.serverTimestamp(),
        'businessInterestSource': source,
        'businessCategories': categoryIds,
        if (convertToBusinessAccount) 'accountType': AccountType.business.value,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      db.collection(AppConstants.businessInterestCollection).doc(),
      {
        'userId': userId,
        'categoryIds': categoryIds,
        'source': source,
        'convertToBusinessAccount': convertToBusinessAccount,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    final stats = _statsDoc;
    if (stats != null) {
      batch.set(
        stats,
        {
          'businessInterestCount': FieldValue.increment(1),
          if (convertToBusinessAccount)
            'businessUserCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Increment listing counters (user + platform + category).
  Future<void> trackListingCreated({
    required String userId,
    required MarketplaceCategory category,
    String? listingId,
  }) async {
    final userRef = _userDoc(userId);
    final db = _db;
    if (userRef == null || db == null) return;

    final batch = db.batch();
    batch.set(
      userRef,
      {
        'listingCount': FieldValue.increment(1),
        'activeListingCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final stats = _statsDoc;
    if (stats != null) {
      batch.set(
        stats,
        {
          'totalListings': FieldValue.increment(1),
          'listingCountByCategory.${category.id}': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    batch.set(
      db.collection(AppConstants.listingEventsCollection).doc(),
      {
        'type': 'created',
        'userId': userId,
        'categoryId': category.id,
        'listingId': ?listingId,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  Future<void> trackListingRemoved({
    required String userId,
    required MarketplaceCategory category,
  }) async {
    final userRef = _userDoc(userId);
    final stats = _statsDoc;
    final db = _db;
    if (userRef == null || db == null) return;

    final batch = db.batch();
    batch.set(
      userRef,
      {
        'activeListingCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    if (stats != null) {
      batch.set(
        stats,
        {
          'activeListings': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<MonetizationUserState> loadUserState(String userId) async {
    final userRef = _userDoc(userId);
    if (userRef == null) return MonetizationUserState(userId: userId);
    try {
      final snap = await userRef.get();
      return MonetizationUserState.fromMap(userId, snap.data());
    } catch (_) {
      return MonetizationUserState(userId: userId);
    }
  }

  Future<Map<String, dynamic>> loadPlatformStats() async {
    final stats = _statsDoc;
    if (stats == null) return {};
    try {
      final snap = await stats.get();
      return snap.data() ?? {};
    } catch (_) {
      return {};
    }
  }
}
