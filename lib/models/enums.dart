import 'package:flutter/material.dart';

enum UserRole {
  student('student'),
  teacher('teacher'),
  administrator('administrator'),
  // Legacy roles
  user('user'),
  verifiedScholar('verified_scholar'),
  moderator('moderator');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }

  bool get isAdmin => this == UserRole.administrator;
  bool get isTeacher => this == UserRole.teacher || isAdmin;
  bool get isStudent => this == UserRole.student || this == UserRole.user;
  bool get isModerator => this == UserRole.moderator || isAdmin;
  bool get isScholar => this == UserRole.verifiedScholar || isTeacher;
}

/// Verified creator badge types shown on profiles.
enum CreatorVerificationType {
  teacher('teacher', 'Verified Teacher', Icons.school_rounded, 0xFF1B5E20),
  islamicScholar('islamic_scholar', 'Verified Scholar', Icons.mosque_rounded, 0xFF2E7D32),
  doctor('doctor', 'Verified Doctor', Icons.medical_services_rounded, 0xFF0277BD),
  nurse('nurse', 'Verified Nurse', Icons.local_hospital_rounded, 0xFF00838F),
  institution('institution', 'Verified Institution', Icons.account_balance_rounded, 0xFF4527A0),
  university('university', 'Verified University', Icons.school_rounded, 0xFF1565C0),
  hospital('hospital', 'Verified Hospital', Icons.local_hospital_rounded, 0xFFC62828);

  const CreatorVerificationType(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final int color;

  static CreatorVerificationType? fromString(String? value) {
    if (value == null) return null;
    for (final type in CreatorVerificationType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

enum VerificationStatus {
  none('none'),
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String? value) {
    return VerificationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => VerificationStatus.none,
    );
  }

  bool get isVerified => this == VerificationStatus.approved;
}

enum AccountStatus {
  active('active'),
  suspended('suspended'),
  banned('banned');

  const AccountStatus(this.value);
  final String value;

  static AccountStatus fromString(String value) {
    return AccountStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => AccountStatus.active,
    );
  }
}

enum VideoStatus {
  pending('pending'),
  processing('processing'),
  approved('approved'),
  rejected('rejected'),
  removed('removed');

  const VideoStatus(this.value);
  final String value;

  static VideoStatus fromString(String value) {
    return VideoStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => VideoStatus.pending,
    );
  }
}

enum ModerationDecision {
  approve('approve'),
  reject('reject'),
  review('review');

  const ModerationDecision(this.value);
  final String value;

  static ModerationDecision fromString(String value) {
    return ModerationDecision.values.firstWhere(
      (d) => d.value == value,
      orElse: () => ModerationDecision.review,
    );
  }
}

enum ReportReason {
  inappropriateContent('inappropriate_content'),
  musicOrEntertainment('music_or_entertainment'),
  violence('violence'),
  hateSpeech('hate_speech'),
  misinformation('misinformation'),
  spam('spam'),
  other('other');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (r) => r.value == value,
      orElse: () => ReportReason.other,
    );
  }
}

enum FeedType {
  forYou('for_you'),
  following('following'),
  trending('trending');

  const FeedType(this.value);
  final String value;

  static FeedType fromString(String value) {
    return FeedType.values.firstWhere(
      (f) => f.value == value,
      orElse: () => FeedType.forYou,
    );
  }
}

enum VideoPrivacy {
  public('public'),
  followers('followers'),
  private('private');

  const VideoPrivacy(this.value);
  final String value;

  static VideoPrivacy fromString(String value) {
    return VideoPrivacy.values.firstWhere(
      (p) => p.value == value,
      orElse: () => VideoPrivacy.public,
    );
  }
}

enum NotificationType {
  // Social
  like('like'),
  comment('comment'),
  follow('follow'),
  mention('mention'),
  reply('reply'),
  live('live'),
  moderation('moderation'),
  // Learning
  newLesson('new_lesson'),
  liveClass('live_class'),
  homework('homework'),
  quizDeadline('quiz_deadline'),
  announcement('announcement'),
  certificate('certificate'),
  grade('grade'),
  // Medical
  medicalLive('medical_live'),
  healthTip('health_tip'),
  system('system');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

enum LiveStreamStatus {
  scheduled('scheduled'),
  live('live'),
  ended('ended');

  const LiveStreamStatus(this.value);
  final String value;

  static LiveStreamStatus fromString(String value) {
    return LiveStreamStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => LiveStreamStatus.scheduled,
    );
  }
}

enum DonationType {
  sadaqah('sadaqah'),
  zakat('zakat'),
  general('general');

  const DonationType(this.value);
  final String value;
}

enum SubscriptionTier {
  supporter('supporter'),
  premium('premium'),
  scholar('scholar');

  const SubscriptionTier(this.value);
  final String value;
}
