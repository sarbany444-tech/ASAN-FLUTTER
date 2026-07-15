import 'enums.dart';

class ModerationResult {
  const ModerationResult({
    required this.decision,
    required this.score,
    required this.flags,
    this.transcript,
    this.detectedKeywords = const [],
    this.prohibitedKeywords = const [],
    this.frameAnalysisNotes,
    this.audioAnalysisNotes,
    this.reviewedBy,
    this.reviewedAt,
  });

  final ModerationDecision decision;
  final double score;
  final List<String> flags;
  final String? transcript;
  final List<String> detectedKeywords;
  final List<String> prohibitedKeywords;
  final String? frameAnalysisNotes;
  final String? audioAnalysisNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  bool get isApproved => decision == ModerationDecision.approve;
  bool get isRejected => decision == ModerationDecision.reject;
  bool get needsReview => decision == ModerationDecision.review;

  factory ModerationResult.fromMap(Map<String, dynamic> map) {
    return ModerationResult(
      decision: ModerationDecision.fromString(
        map['decision'] as String? ?? 'review',
      ),
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      flags: List<String>.from(map['flags'] as List? ?? []),
      transcript: map['transcript'] as String?,
      detectedKeywords: List<String>.from(map['detectedKeywords'] as List? ?? []),
      prohibitedKeywords: List<String>.from(
        map['prohibitedKeywords'] as List? ?? [],
      ),
      frameAnalysisNotes: map['frameAnalysisNotes'] as String?,
      audioAnalysisNotes: map['audioAnalysisNotes'] as String?,
      reviewedBy: map['reviewedBy'] as String?,
      reviewedAt: map['reviewedAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'decision': decision.value,
      'score': score,
      'flags': flags,
      'transcript': transcript,
      'detectedKeywords': detectedKeywords,
      'prohibitedKeywords': prohibitedKeywords,
      'frameAnalysisNotes': frameAnalysisNotes,
      'audioAnalysisNotes': audioAnalysisNotes,
      'reviewedBy': reviewedBy,
    };
  }
}

class ReportModel {
  const ReportModel({
    required this.id,
    required this.videoId,
    required this.reporterId,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final String videoId;
  final String reporterId;
  final ReportReason reason;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      videoId: map['videoId'] as String? ?? '',
      reporterId: map['reporterId'] as String? ?? '',
      reason: ReportReason.fromString(map['reason'] as String? ?? 'other'),
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt']?.toDate() as DateTime?,
      reviewedBy: map['reviewedBy'] as String?,
      reviewedAt: map['reviewedAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'reporterId': reporterId,
      'reason': reason.value,
      'description': description,
      'status': status,
      'reviewedBy': reviewedBy,
    };
  }
}

class CommentModel {
  const CommentModel({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.userDisplayName,
    required this.text,
    this.userPhotoUrl,
    this.createdAt,
  });

  final String id;
  final String videoId;
  final String userId;
  final String userDisplayName;
  final String text;
  final String? userPhotoUrl;
  final DateTime? createdAt;

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      videoId: map['videoId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userDisplayName: map['userDisplayName'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'text': text,
      'userPhotoUrl': userPhotoUrl,
    };
  }
}

class DailyContentModel {
  const DailyContentModel({
    required this.type,
    required this.arabicText,
    required this.translation,
    this.reference,
    this.source,
    this.date,
  });

  final String type;
  final String arabicText;
  final String translation;
  final String? reference;
  final String? source;
  final DateTime? date;

  factory DailyContentModel.fromMap(Map<String, dynamic> map) {
    return DailyContentModel(
      type: map['type'] as String? ?? '',
      arabicText: map['arabicText'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      reference: map['reference'] as String?,
      source: map['source'] as String?,
      date: map['date']?.toDate() as DateTime?,
    );
  }
}
