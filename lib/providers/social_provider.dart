import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/follow_service.dart';
import '../services/social_service.dart';
import '../models/video_model.dart';

class SocialProvider extends ChangeNotifier {
  SocialProvider({
    FollowService? followService,
    SocialService? socialService,
  })  : _followService = followService ?? FollowService(),
        _socialService = socialService ?? SocialService();

  final FollowService _followService;
  final SocialService _socialService;

  List<VideoModel> _savedVideos = [];
  List<VideoModel> _historyVideos = [];
  bool _isFollowing = false;

  List<VideoModel> get savedVideos => _savedVideos;
  List<VideoModel> get historyVideos => _historyVideos;
  bool get isFollowing => _isFollowing;

  Future<void> follow(String followerId, String followingId, String followerName) async {
    await _followService.follow(
      followerId: followerId,
      followingId: followingId,
      followerName: followerName,
    );
    _isFollowing = true;
    notifyListeners();
  }

  Future<void> unfollow(String followerId, String followingId) async {
    await _followService.unfollow(followerId: followerId, followingId: followingId);
    _isFollowing = false;
    notifyListeners();
  }

  Future<void> checkFollowing(String followerId, String followingId) async {
    _isFollowing = await _followService.isFollowing(followerId, followingId);
    notifyListeners();
  }

  Future<void> loadSavedVideos(String userId) async {
    _savedVideos = await _socialService.getSavedVideos(userId);
    notifyListeners();
  }

  Future<void> loadWatchHistory(String userId) async {
    _historyVideos = await _socialService.getWatchHistoryVideos(userId);
    notifyListeners();
  }

  Stream<List<UserModel>> watchFollowers(String userId) =>
      _followService.watchFollowers(userId);

  Stream<List<UserModel>> watchFollowing(String userId) =>
      _followService.watchFollowing(userId);
}
