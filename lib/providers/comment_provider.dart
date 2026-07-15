import 'package:flutter/material.dart';
import '../models/social_models.dart';
import '../services/comment_service.dart';
import '../services/notification_service.dart';

class CommentProvider extends ChangeNotifier {
  CommentProvider({CommentService? commentService})
      : _commentService = commentService ?? CommentService();

  final CommentService _commentService;
  List<CommentModel> _comments = [];
  String? _activeVideoId;

  List<CommentModel> get comments => _comments;
  String? get activeVideoId => _activeVideoId;

  void watchComments(String videoId) {
    _activeVideoId = videoId;
    _commentService.watchComments(videoId).listen((comments) {
      _comments = comments;
      notifyListeners();
    });
  }

  Future<void> addComment({
    required String videoId,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String text,
    String? parentCommentId,
    List<String> mentions = const [],
    String? videoOwnerId,
  }) async {
    await _commentService.addComment(
      videoId: videoId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPhotoUrl: userPhotoUrl,
      text: text,
      parentCommentId: parentCommentId,
      mentions: mentions,
    );

    if (videoOwnerId != null && videoOwnerId != userId) {
      await NotificationService().sendNotification(
        userId: videoOwnerId,
        type: parentCommentId != null ? 'reply' : 'comment',
        title: parentCommentId != null ? 'New Reply' : 'New Comment',
        body: '$userDisplayName: $text',
        fromUserId: userId,
        fromUserName: userDisplayName,
        videoId: videoId,
      );
    }
  }

  Future<void> toggleLike(String commentId, String userId) async {
    await _commentService.toggleCommentLike(commentId, userId);
  }
}
