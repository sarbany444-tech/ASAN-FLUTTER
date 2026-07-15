import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/constants/content_policy.dart';
import '../core/theme/app_colors.dart';
import '../models/video_model.dart';
import '../services/video_preload_manager.dart';

class TikTokVideoPlayer extends StatefulWidget {
  const TikTokVideoPlayer({
    super.key,
    required this.video,
    required this.isActive,
    this.onTap,
  });

  final VideoModel video;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(TikTokVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _handleActiveChange();
    }
    if (widget.video.id != oldWidget.video.id) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    if (widget.video.videoUrl.isEmpty) return;

    try {
      _controller = await VideoPreloadManager.instance.getOrCreate(
        widget.video.id,
        widget.video.videoUrl,
      );
      if (mounted) {
        setState(() => _initialized = true);
        if (widget.isActive) {
          await VideoPreloadManager.instance.setActive(widget.video.id);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _initialized = false);
    }
  }

  Future<void> _handleActiveChange() async {
    if (!_initialized || _controller == null) return;
    if (widget.isActive) {
      await VideoPreloadManager.instance.setActive(widget.video.id);
    } else {
      await _controller!.pause();
    }
  }

  void _onTap() {
    if (_controller == null) return;
    setState(() => _showPlayIcon = true);
    VideoPreloadManager.instance.togglePlayPause();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showPlayIcon = false);
    });
    widget.onTap?.call();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        ContentPolicy.categoryLabels[widget.video.category] ?? widget.video.category;

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            _buildPlaceholder(),

          // Text overlays
          ...widget.video.textOverlays.map(
            (overlay) => Positioned(
              left: (overlay['x'] as num?)?.toDouble() ?? 0,
              top: (overlay['y'] as num?)?.toDouble() ?? 0,
              child: Text(
                overlay['text'] as String? ?? '',
                style: TextStyle(
                  color: Color(int.parse(
                    ((overlay['color'] as String?) ?? '#FFFFFF')
                        .replaceFirst('#', '0xFF'),
                  )),
                  fontSize: (overlay['fontSize'] as num?)?.toDouble() ?? 16,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ),

          // Filter tint overlay
          if (widget.video.filterName != null)
            _FilterOverlay(filterName: widget.video.filterName!),

          // Captions
          if (widget.video.captions != null && widget.video.captions!.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 16,
              right: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.video.captions!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          if (_showPlayIcon)
            Center(
              child: Icon(
                _controller?.value.isPlaying ?? false
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 72,
                color: Colors.white54,
              ),
            ),

          // Category badge
          Positioned(
            top: 100,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
              ),
              child: Text(
                categoryLabel,
                style: const TextStyle(color: AppColors.accentGoldLight, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryGreenDark,
      child: widget.video.thumbnailUrl != null
          ? Image.network(widget.video.thumbnailUrl!, fit: BoxFit.cover)
          : Center(
              child: Icon(Icons.play_circle_outline,
                  size: 80, color: Colors.white.withValues(alpha: 0.4)),
            ),
    );
  }
}

class _FilterOverlay extends StatelessWidget {
  const _FilterOverlay({required this.filterName});
  final String filterName;

  @override
  Widget build(BuildContext context) {
    final color = switch (filterName) {
      'warm' => Colors.orange.withValues(alpha: 0.15),
      'cool' => Colors.blue.withValues(alpha: 0.15),
      'vintage' => Colors.brown.withValues(alpha: 0.2),
      'bright' => Colors.yellow.withValues(alpha: 0.1),
      _ => Colors.transparent,
    };
    return Container(color: color);
  }
}
