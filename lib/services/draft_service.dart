import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/social_models.dart';

class DraftService {
  DraftService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _localKey = 'naseem_video_drafts';

  Future<void> saveDraftLocal(VideoDraftModel draft) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDraftsLocal();
    existing.removeWhere((d) => d.id == draft.id);
    existing.insert(0, draft);
    final encoded = existing.map((d) => jsonEncode({
          'id': d.id,
          ...d.toMap(),
          'updatedAt': DateTime.now().toIso8601String(),
        })).toList();
    await prefs.setStringList(_localKey, encoded);
  }

  Future<List<VideoDraftModel>> getDraftsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_localKey) ?? [];
    return list.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return VideoDraftModel.fromMap(map, map['id'] as String);
    }).toList();
  }

  Future<void> deleteDraftLocal(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDraftsLocal();
    existing.removeWhere((d) => d.id == draftId);
    final encoded = existing.map((d) => jsonEncode({'id': d.id, ...d.toMap()})).toList();
    await prefs.setStringList(_localKey, encoded);
  }

  Future<void> saveDraftCloud(VideoDraftModel draft) async {
    await _firestore
        .collection(AppConstants.draftsCollection)
        .doc(draft.id)
        .set({
      ...draft.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<VideoDraftModel>> watchCloudDrafts(String userId) {
    return _firestore
        .collection(AppConstants.draftsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => VideoDraftModel.fromMap(d.data(), d.id))
            .toList());
  }
}
