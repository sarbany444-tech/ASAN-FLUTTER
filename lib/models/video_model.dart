import 'enums.dart';

class VideoModel {
  const VideoModel({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    this.thumbnailUrl,
    this.userPhotoUrl,
    this.transcript,
    this.captions,
    this.filterName,
    this.durationSeconds = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.saveCount = 0,
    this.status = VideoStatus.pending,
    this.privacy = VideoPrivacy.public,
    this.moderationScore = 0.0,
    this.moderationFlags = const [],
    this.engagementScore = 0.0,
    this.trendingScore = 0.0,
    this.isUserVerified = false,
    this.createdAt,
    this.likedBy = const [],
    this.savedBy = const [],
    this.hashtags = const [],
    this.textOverlays = const [],
  });

  final String id;
  final String userId;
  final String userDisplayName;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? userPhotoUrl;
  final String? transcript;
  final String? captions;
  final String? filterName;
  final int durationSeconds;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final int saveCount;
  final VideoStatus status;
  final VideoPrivacy privacy;
  final double moderationScore;
  final List<String> moderationFlags;
  final double engagementScore;
  final double trendingScore;
  final bool isUserVerified;
  final DateTime? createdAt;
  final List<String> likedBy;
  final List<String> savedBy;
  final List<String> hashtags;
  final List<Map<String, dynamic>> textOverlays;

  bool get isPublished => status == VideoStatus.approved;
  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isSavedBy(String userId) => savedBy.contains(userId);

  VideoModel copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? viewCount,
    int? saveCount,
    VideoStatus? status,
    List<String>? likedBy,
    List<String>? savedBy,
  }) {
    return VideoModel(
      id: id,
      userId: userId,
      userDisplayName: userDisplayName,
      title: title,
      description: description,
      category: category,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      userPhotoUrl: userPhotoUrl,
      transcript: transcript,
      captions: captions,
      filterName: filterName,
      durationSeconds: durationSeconds,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      saveCount: saveCount ?? this.saveCount,
      status: status ?? this.status,
      privacy: privacy,
      moderationScore: moderationScore,
      moderationFlags: moderationFlags,
      engagementScore: engagementScore,
      trendingScore: trendingScore,
      isUserVerified: isUserVerified,
      createdAt: createdAt,
      likedBy: likedBy ?? this.likedBy,
      savedBy: savedBy ?? this.savedBy,
      hashtags: hashtags,
      textOverlays: textOverlays,
    );
  }

  factory VideoModel.fromMap(Map<String, dynamic> map, String id) {
    return VideoModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userDisplayName: map['userDisplayName'] as String? ?? 'User',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'general_education',
      videoUrl: map['videoUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      userPhotoUrl: map['userPhotoUrl'] as String?,
      transcript: map['transcript'] as String?,
      captions: map['captions'] as String?,
      filterName: map['filterName'] as String?,
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      likeCount: map['likeCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      shareCount: map['shareCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      saveCount: map['saveCount'] as int? ?? 0,
      status: VideoStatus.fromString(map['status'] as String? ?? 'pending'),
      privacy: VideoPrivacy.fromString(map['privacy'] as String? ?? 'public'),
      moderationScore: (map['moderationScore'] as num?)?.toDouble() ?? 0.0,
      moderationFlags: List<String>.from(map['moderationFlags'] as List? ?? []),
      engagementScore: (map['engagementScore'] as num?)?.toDouble() ?? 0.0,
      trendingScore: (map['trendingScore'] as num?)?.toDouble() ?? 0.0,
      isUserVerified: map['isUserVerified'] as bool? ?? false,
      createdAt: map['createdAt']?.toDate() as DateTime?,
      likedBy: List<String>.from(map['likedBy'] as List? ?? []),
      savedBy: List<String>.from(map['savedBy'] as List? ?? []),
      hashtags: List<String>.from(map['hashtags'] as List? ?? []),
      textOverlays: List<Map<String, dynamic>>.from(
        (map['textOverlays'] as List? ?? []).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'userPhotoUrl': userPhotoUrl,
      'transcript': transcript,
      'captions': captions,
      'filterName': filterName,
      'durationSeconds': durationSeconds,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'viewCount': viewCount,
      'saveCount': saveCount,
      'status': status.value,
      'privacy': privacy.value,
      'moderationScore': moderationScore,
      'moderationFlags': moderationFlags,
      'engagementScore': engagementScore,
      'trendingScore': trendingScore,
      'isUserVerified': isUserVerified,
      'likedBy': likedBy,
      'savedBy': savedBy,
      'hashtags': hashtags,
      'textOverlays': textOverlays,
    };
  }
}
