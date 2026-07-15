import 'package:video_player/video_player.dart';
import '../core/constants/app_constants.dart';

/// Preloads adjacent videos for smooth TikTok-style scrolling.
class VideoPreloadManager {
  VideoPreloadManager._();
  static final VideoPreloadManager instance = VideoPreloadManager._();

  final Map<String, VideoPlayerController> _controllers = {};
  String? _activeVideoId;

  VideoPlayerController? getController(String videoId) => _controllers[videoId];

  String? get activeVideoId => _activeVideoId;

  Future<VideoPlayerController> getOrCreate(String videoId, String url) async {
    if (_controllers.containsKey(videoId)) {
      return _controllers[videoId]!;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    _controllers[videoId] = controller;
    return controller;
  }

  Future<void> setActive(String videoId) async {
    if (_activeVideoId == videoId) return;

    for (final entry in _controllers.entries) {
      if (entry.key == videoId) {
        await entry.value.play();
      } else {
        await entry.value.pause();
        await entry.value.seekTo(Duration.zero);
      }
    }
    _activeVideoId = videoId;
  }

  Future<void> preloadAdjacent({
    required List<String> videoIds,
    required List<String> videoUrls,
    required int currentIndex,
  }) async {
    final start = (currentIndex - AppConstants.preloadVideoCount).clamp(0, videoIds.length);
    final end = (currentIndex + AppConstants.preloadVideoCount + 1).clamp(0, videoIds.length);

    for (var i = start; i < end; i++) {
      if (i < videoIds.length && i < videoUrls.length && videoUrls[i].isNotEmpty) {
        await getOrCreate(videoIds[i], videoUrls[i]);
      }
    }

    // Dispose far-away controllers to save memory
    final keepIds = videoIds.sublist(start, end).toSet();
    final toRemove = _controllers.keys.where((id) => !keepIds.contains(id)).toList();
    for (final id in toRemove) {
      if (id != _activeVideoId) {
        await _controllers[id]?.dispose();
        _controllers.remove(id);
      }
    }
  }

  void togglePlayPause() {
    final active = _activeVideoId != null ? _controllers[_activeVideoId] : null;
    if (active == null) return;
    if (active.value.isPlaying) {
      active.pause();
    } else {
      active.play();
    }
  }

  Future<void> disposeAll() async {
    for (final c in _controllers.values) {
      await c.dispose();
    }
    _controllers.clear();
    _activeVideoId = null;
  }
}
