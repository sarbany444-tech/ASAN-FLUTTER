import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/video_model.dart';
import '../models/social_models.dart';
import '../services/feed_service.dart';
import '../services/video_service.dart';
import '../services/social_service.dart';
import '../services/discovery_service.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider({
    FeedService? feedService,
    VideoService? videoService,
    SocialService? socialService,
    DiscoveryService? discoveryService,
  })  : _feedService = feedService ?? FeedService(),
        _videoService = videoService ?? VideoService(),
        _socialService = socialService ?? SocialService(),
        _discoveryService = discoveryService ?? DiscoveryService();

  final FeedService _feedService;
  final VideoService _videoService;
  final SocialService _socialService;
  final DiscoveryService _discoveryService;

  FeedType _feedType = FeedType.forYou;
  List<VideoModel> _videos = [];
  List<VideoModel> _trendingVideos = [];
  List<VideoModel> _categoryVideos = [];
  List<WatchHistoryEntry> _watchHistory = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _selectedCategory;
  int _currentIndex = 0;

  FeedType get feedType => _feedType;
  List<VideoModel> get videos => _videos;
  List<VideoModel> get trendingVideos => _trendingVideos;
  List<VideoModel> get categoryVideos => _categoryVideos;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get currentIndex => _currentIndex;
  String? get selectedCategory => _selectedCategory;
  bool get hasMore =>
      _feedType == FeedType.following
          ? _feedService.hasMoreFollowing
          : _feedService.hasMoreForYou;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> loadFeed({
    required FeedType type,
    required String? userId,
    List<String> followingIds = const [],
  }) async {
    _feedType = type;
    _isLoading = true;
    _feedService.resetPagination();
    notifyListeners();

    try {
      if (userId != null) {
        try {
          _watchHistory = await _feedService.getWatchHistory(userId);
        } catch (_) {
          _watchHistory = [];
        }
      }

      if (type == FeedType.forYou) {
        _videos = await _feedService.fetchForYouPage(
          watchHistory: _watchHistory,
          followingIds: followingIds,
        );
      } else if (type == FeedType.following) {
        _videos = await _feedService.fetchFollowingPage(followingIds);
      } else {
        _videos = await _feedService.fetchTrending();
      }
    } catch (_) {
      _videos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({List<String> followingIds = const []}) async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    List<VideoModel> more;
    if (_feedType == FeedType.following) {
      more = await _feedService.fetchFollowingPage(followingIds);
    } else {
      more = await _feedService.fetchForYouPage(
        watchHistory: _watchHistory,
        followingIds: followingIds,
      );
    }

    _videos = [..._videos, ...more];
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadTrending() async {
    _trendingVideos = await _feedService.fetchTrending();
    notifyListeners();
  }

  void listenToCategory(String category) {
    _selectedCategory = category;
    _videoService.getApprovedFeed(category: category).listen((videos) {
      _categoryVideos = videos;
      notifyListeners();
    });
  }

  Future<void> toggleLike(String videoId, String userId) async {
    await _videoService.toggleLike(videoId, userId);
    _updateLocalVideo(videoId, (v) {
      final liked = v.likedBy.contains(userId);
      return v.copyWith(
        likeCount: v.likeCount + (liked ? -1 : 1),
        likedBy: liked
            ? v.likedBy.where((id) => id != userId).toList()
            : [...v.likedBy, userId],
      );
    });
  }

  Future<void> toggleSave(String videoId, String userId) async {
    await _socialService.toggleSave(videoId, userId);
    _updateLocalVideo(videoId, (v) {
      final saved = v.savedBy.contains(userId);
      return v.copyWith(
        saveCount: v.saveCount + (saved ? -1 : 1),
        savedBy: saved
            ? v.savedBy.where((id) => id != userId).toList()
            : [...v.savedBy, userId],
      );
    });
  }

  Future<void> recordView(String userId, VideoModel video) async {
    await _videoService.incrementViewCount(video.id);
    await _feedService.recordWatch(
      userId: userId,
      videoId: video.id,
      category: video.category,
    );
  }

  Future<void> incrementShare(String videoId) async {
    await _videoService.incrementShareCount(videoId);
  }

  Future<List<VideoModel>> searchVideos(String q) =>
      _discoveryService.searchVideos(q);

  void _updateLocalVideo(String videoId, VideoModel Function(VideoModel) update) {
    _videos = _videos.map((v) => v.id == videoId ? update(v) : v).toList();
    notifyListeners();
  }
}
