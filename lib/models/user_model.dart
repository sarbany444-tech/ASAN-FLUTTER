import 'enums.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.role = UserRole.student,
    this.creatorVerificationType,
    this.verificationStatus = VerificationStatus.none,
    this.status = AccountStatus.active,
    this.strikeCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.videoCount = 0,
    this.isVerified = false,
    this.preferredLanguage = 'en',
    this.createdAt,
    this.suspendedUntil,
    this.followingIds = const [],
    this.savedVideoIds = const [],
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final UserRole role;
  final CreatorVerificationType? creatorVerificationType;
  final VerificationStatus verificationStatus;
  final AccountStatus status;
  final int strikeCount;
  final int followerCount;
  final int followingCount;
  final int videoCount;
  final bool isVerified;
  final String preferredLanguage;
  final DateTime? createdAt;
  final DateTime? suspendedUntil;
  final List<String> followingIds;
  final List<String> savedVideoIds;

  bool get canUpload =>
      status == AccountStatus.active && strikeCount < 5;

  bool get isSuspended => status == AccountStatus.suspended;
  bool get isBanned => status == AccountStatus.banned;
  bool get isVerifiedCreator =>
      verificationStatus.isVerified && creatorVerificationType != null;
  bool get isScholar =>
      role.isScholar ||
      creatorVerificationType == CreatorVerificationType.islamicScholar;
  bool get isMedicalCreator =>
      creatorVerificationType == CreatorVerificationType.doctor ||
      creatorVerificationType == CreatorVerificationType.nurse;

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    UserRole? role,
    CreatorVerificationType? creatorVerificationType,
    VerificationStatus? verificationStatus,
    AccountStatus? status,
    int? strikeCount,
    int? followerCount,
    int? followingCount,
    int? videoCount,
    bool? isVerified,
    String? preferredLanguage,
    DateTime? suspendedUntil,
    List<String>? followingIds,
    List<String>? savedVideoIds,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      creatorVerificationType:
          creatorVerificationType ?? this.creatorVerificationType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      status: status ?? this.status,
      strikeCount: strikeCount ?? this.strikeCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      videoCount: videoCount ?? this.videoCount,
      isVerified: isVerified ?? this.isVerified,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      followingIds: followingIds ?? this.followingIds,
      savedVideoIds: savedVideoIds ?? this.savedVideoIds,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'student'),
      creatorVerificationType: CreatorVerificationType.fromString(
        map['creatorVerificationType'] as String?,
      ),
      verificationStatus: VerificationStatus.fromString(
        map['verificationStatus'] as String?,
      ),
      status: AccountStatus.fromString(map['status'] as String? ?? 'active'),
      strikeCount: map['strikeCount'] as int? ?? 0,
      followerCount: map['followerCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
      videoCount: map['videoCount'] as int? ?? 0,
      isVerified: map['isVerified'] as bool? ?? false,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      createdAt: map['createdAt']?.toDate() as DateTime?,
      suspendedUntil: map['suspendedUntil']?.toDate() as DateTime?,
      followingIds: List<String>.from(map['followingIds'] as List? ?? []),
      savedVideoIds: List<String>.from(map['savedVideoIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role.value,
      'creatorVerificationType': creatorVerificationType?.value,
      'verificationStatus': verificationStatus.value,
      'status': status.value,
      'strikeCount': strikeCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'videoCount': videoCount,
      'isVerified': isVerified,
      'preferredLanguage': preferredLanguage,
      'followingIds': followingIds,
      'savedVideoIds': savedVideoIds,
    };
  }
}
