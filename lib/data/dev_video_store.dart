import '../models/video_model.dart';

/// In-memory videos uploaded during local/web development (no Firebase).
class DevVideoStore {
  DevVideoStore._();

  static final DevVideoStore instance = DevVideoStore._();

  final List<VideoModel> _videos = [];

  List<VideoModel> get videos => List.unmodifiable(_videos);

  void addVideo(VideoModel video) {
    _videos.insert(0, video);
  }

  void clear() => _videos.clear();
}
