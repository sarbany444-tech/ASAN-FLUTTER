import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  VideoProvider({VideoService? videoService})
      : _videoService = videoService ?? VideoService();

  final VideoService _videoService;
  List<VideoModel> _feedVideos = [];
  List<VideoModel> _categoryVideos = [];
  final bool _isLoading = false;
  String? _selectedCategory;

  List<VideoModel> get feedVideos => _feedVideos;
  List<VideoModel> get categoryVideos => _categoryVideos;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  void listenToFeed() {
    _videoService.getApprovedFeed().listen((videos) {
      _feedVideos = videos;
      notifyListeners();
    });
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
  }

  Future<void> incrementView(String videoId) async {
    await _videoService.incrementViewCount(videoId);
  }

  Future<List<VideoModel>> search(String query) async {
    return _videoService.searchVideos(query);
  }
}
