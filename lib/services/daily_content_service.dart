import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/enums.dart';
import '../models/moderation_result.dart';

class DailyContentService {
  DailyContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<DailyContentModel?> getDailyQuranVerse() async {
    final doc = await _firestore
        .collection(AppConstants.dailyContentCollection)
        .doc('quran_verse')
        .get();

    if (doc.exists) {
      return DailyContentModel.fromMap(doc.data()!);
    }

    // Fallback curated content
    return const DailyContentModel(
      type: 'quran',
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      translation: 'Indeed, with hardship comes ease.',
      reference: 'Quran 94:6',
      source: 'Surah Ash-Sharh',
    );
  }

  Future<DailyContentModel?> getDailyHadith() async {
    final doc = await _firestore
        .collection(AppConstants.dailyContentCollection)
        .doc('hadith')
        .get();

    if (doc.exists) {
      return DailyContentModel.fromMap(doc.data()!);
    }

    return const DailyContentModel(
      type: 'hadith',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      translation: 'Actions are judged by intentions.',
      reference: 'Sahih al-Bukhari & Muslim',
      source: 'Hadith of Umar ibn al-Khattab (RA)',
    );
  }

  Future<DailyContentModel?> getDailyReminder() async {
    final doc = await _firestore
        .collection(AppConstants.dailyContentCollection)
        .doc('reminder')
        .get();

    if (doc.exists) {
      return DailyContentModel.fromMap(doc.data()!);
    }

    return const DailyContentModel(
      type: 'reminder',
      arabicText: 'اذْكُرُوا اللَّهَ كَثِيرًا',
      translation: 'Remember Allah often.',
      reference: 'Daily Reminder',
      source: 'Naseem Reminders',
    );
  }
}

class ReportService {
  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitReport({
    required String videoId,
    required String reporterId,
    required ReportReason reason,
    String? description,
  }) async {
    await _firestore.collection(AppConstants.reportsCollection).add({
      'videoId': videoId,
      'reporterId': reporterId,
      'reason': reason.value,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ReportModel>> getPendingReports() {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

class AdminService {
  AdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> getModerationQueue() {
    return _firestore
        .collection(AppConstants.moderationQueueCollection)
        .where('status', isEqualTo: 'pending_review')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> approveVideo(String videoId, String adminId) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'status': 'approved'});
    await _firestore
        .collection(AppConstants.moderationQueueCollection)
        .doc(videoId)
        .update({
      'status': 'approved',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectVideo(String videoId, String adminId, String reason) async {
    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(videoId)
        .update({'status': 'rejected', 'rejectionReason': reason});
    await _firestore
        .collection(AppConstants.moderationQueueCollection)
        .doc(videoId)
        .update({
      'status': 'rejected',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'role': role});
  }

  Future<void> banUser(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'status': 'banned'});
  }

  Future<Map<String, int>> getDashboardStats() async {
    final users = await _firestore.collection(AppConstants.usersCollection).count().get();
    final videos = await _firestore
        .collection(AppConstants.videosCollection)
        .where('status', isEqualTo: 'approved')
        .count()
        .get();
    final pending = await _firestore
        .collection(AppConstants.moderationQueueCollection)
        .where('status', isEqualTo: 'pending_review')
        .count()
        .get();
    final reports = await _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    return {
      'users': users.count ?? 0,
      'videos': videos.count ?? 0,
      'pendingModeration': pending.count ?? 0,
      'pendingReports': reports.count ?? 0,
    };
  }
}
