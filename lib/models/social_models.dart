class CommentModel {
  const CommentModel({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.userDisplayName,
    required this.text,
    this.userPhotoUrl,
    this.parentCommentId,
    this.mentions = const [],
    this.likeCount = 0,
    this.replyCount = 0,
    this.likedBy = const [],
    this.createdAt,
  });

  final String id;
  final String videoId;
  final String userId;
  final String userDisplayName;
  final String text;
  final String? userPhotoUrl;
  final String? parentCommentId;
  final List<String> mentions;
  final int likeCount;
  final int replyCount;
  final List<String> likedBy;
  final DateTime? createdAt;

  bool get isReply => parentCommentId != null;
  bool isLikedBy(String userId) => likedBy.contains(userId);

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      videoId: map['videoId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userDisplayName: map['userDisplayName'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      parentCommentId: map['parentCommentId'] as String?,
      mentions: List<String>.from(map['mentions'] as List? ?? []),
      likeCount: map['likeCount'] as int? ?? 0,
      replyCount: map['replyCount'] as int? ?? 0,
      likedBy: List<String>.from(map['likedBy'] as List? ?? []),
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
      'parentCommentId': parentCommentId,
      'mentions': mentions,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'likedBy': likedBy,
    };
  }
}

class HashtagModel {
  const HashtagModel({
    required this.tag,
    this.videoCount = 0,
    this.trendingScore = 0.0,
    this.category,
  });

  final String tag;
  final int videoCount;
  final double trendingScore;
  final String? category;

  factory HashtagModel.fromMap(Map<String, dynamic> map, String id) {
    return HashtagModel(
      tag: map['tag'] as String? ?? id,
      videoCount: map['videoCount'] as int? ?? 0,
      trendingScore: (map['trendingScore'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String?,
    );
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.fromUserId,
    this.fromUserName,
    this.fromUserPhoto,
    this.videoId,
    this.commentId,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? fromUserId;
  final String? fromUserName;
  final String? fromUserPhoto;
  final String? videoId;
  final String? commentId;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      fromUserId: map['fromUserId'] as String?,
      fromUserName: map['fromUserName'] as String?,
      fromUserPhoto: map['fromUserPhoto'] as String?,
      videoId: map['videoId'] as String?,
      commentId: map['commentId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final bool isRead;
  final DateTime? createdAt;

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'text': text,
        'isRead': isRead,
      };
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: map['lastMessageAt']?.toDate() as DateTime?,
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }
}

class VideoDraftModel {
  const VideoDraftModel({
    required this.id,
    required this.userId,
    this.localPath,
    this.title,
    this.description,
    this.category,
    this.hashtags = const [],
    this.privacy = 'public',
    this.textOverlays = const [],
    this.filterName,
    this.trimStartMs = 0,
    this.trimEndMs = 0,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String? localPath;
  final String? title;
  final String? description;
  final String? category;
  final List<String> hashtags;
  final String privacy;
  final List<Map<String, dynamic>> textOverlays;
  final String? filterName;
  final int trimStartMs;
  final int trimEndMs;
  final DateTime? updatedAt;

  factory VideoDraftModel.fromMap(Map<String, dynamic> map, String id) {
    return VideoDraftModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      localPath: map['localPath'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      category: map['category'] as String?,
      hashtags: List<String>.from(map['hashtags'] as List? ?? []),
      privacy: map['privacy'] as String? ?? 'public',
      textOverlays: List<Map<String, dynamic>>.from(
        (map['textOverlays'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      filterName: map['filterName'] as String?,
      trimStartMs: map['trimStartMs'] as int? ?? 0,
      trimEndMs: map['trimEndMs'] as int? ?? 0,
      updatedAt: map['updatedAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'localPath': localPath,
        'title': title,
        'description': description,
        'category': category,
        'hashtags': hashtags,
        'privacy': privacy,
        'textOverlays': textOverlays,
        'filterName': filterName,
        'trimStartMs': trimStartMs,
        'trimEndMs': trimEndMs,
      };
}

class CreatorAnalyticsModel {
  const CreatorAnalyticsModel({
    required this.userId,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalShares = 0,
    this.totalFollowers = 0,
    this.followersGrowth = 0,
    this.viewsLast7Days = const [],
    this.likesLast7Days = const [],
    this.topVideos = const [],
  });

  final String userId;
  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalFollowers;
  final int followersGrowth;
  final List<int> viewsLast7Days;
  final List<int> likesLast7Days;
  final List<String> topVideos;

  factory CreatorAnalyticsModel.fromMap(Map<String, dynamic> map, String userId) {
    return CreatorAnalyticsModel(
      userId: userId,
      totalViews: map['totalViews'] as int? ?? 0,
      totalLikes: map['totalLikes'] as int? ?? 0,
      totalComments: map['totalComments'] as int? ?? 0,
      totalShares: map['totalShares'] as int? ?? 0,
      totalFollowers: map['totalFollowers'] as int? ?? 0,
      followersGrowth: map['followersGrowth'] as int? ?? 0,
      viewsLast7Days: List<int>.from(map['viewsLast7Days'] as List? ?? []),
      likesLast7Days: List<int>.from(map['likesLast7Days'] as List? ?? []),
      topVideos: List<String>.from(map['topVideos'] as List? ?? []),
    );
  }
}

class LiveStreamModel {
  const LiveStreamModel({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.title,
    this.category,
    this.status = 'scheduled',
    this.viewerCount = 0,
    this.streamUrl,
    this.thumbnailUrl,
    this.startedAt,
  });

  final String id;
  final String hostId;
  final String hostName;
  final String title;
  final String? category;
  final String status;
  final int viewerCount;
  final String? streamUrl;
  final String? thumbnailUrl;
  final DateTime? startedAt;

  bool get isLive => status == 'live';

  factory LiveStreamModel.fromMap(Map<String, dynamic> map, String id) {
    return LiveStreamModel(
      id: id,
      hostId: map['hostId'] as String? ?? '',
      hostName: map['hostName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String?,
      status: map['status'] as String? ?? 'scheduled',
      viewerCount: map['viewerCount'] as int? ?? 0,
      streamUrl: map['streamUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      startedAt: map['startedAt']?.toDate() as DateTime?,
    );
  }
}

class WatchHistoryEntry {
  const WatchHistoryEntry({
    required this.videoId,
    required this.userId,
    this.watchedAt,
    this.watchDurationSeconds = 0,
    this.category,
  });

  final String videoId;
  final String userId;
  final DateTime? watchedAt;
  final int watchDurationSeconds;
  final String? category;
}
