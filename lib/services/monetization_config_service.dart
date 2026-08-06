import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/monetization/monetization.dart';
import 'firebase_service.dart';

/// Loads admin-controlled monetization config from Firestore.
///
/// Document: `config/monetization`
/// Falls back to [MonetizationConfig.launchDefaults] when offline / missing
/// so first-time UX stays unrestricted.
class MonetizationConfigService {
  MonetizationConfigService({this._firestore});

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialized) return null;
    return _firestore ??= FirebaseFirestore.instance;
  }

  DocumentReference<Map<String, dynamic>>? get _doc {
    final db = _db;
    if (db == null) return null;
    return db
        .collection(AppConstants.configCollection)
        .doc(AppConstants.monetizationConfigDoc);
  }

  /// One-shot read with safe launch defaults.
  Future<MonetizationConfig> fetch() async {
    final doc = _doc;
    if (doc == null) return MonetizationConfig.launchDefaults();
    try {
      final snap = await doc.get();
      return MonetizationConfig.fromMap(snap.data());
    } catch (_) {
      return MonetizationConfig.launchDefaults();
    }
  }

  /// Live updates — admin changes apply without an app release.
  Stream<MonetizationConfig> watch() {
    final doc = _doc;
    if (doc == null) {
      return Stream.value(MonetizationConfig.launchDefaults());
    }
    return doc.snapshots().map((snap) {
      try {
        if (!snap.exists) return MonetizationConfig.launchDefaults();
        return MonetizationConfig.fromMap(snap.data());
      } catch (_) {
        return MonetizationConfig.launchDefaults();
      }
    });
  }

  /// Admin-only write helper (client enforces via Firestore rules).
  Future<void> save(MonetizationConfig config, {String? updatedBy}) async {
    final doc = _doc;
    if (doc == null) {
      throw StateError('Firebase is not initialized');
    }
    await doc.set({
      ...config.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': ?updatedBy,
    }, SetOptions(merge: true));
  }
}
