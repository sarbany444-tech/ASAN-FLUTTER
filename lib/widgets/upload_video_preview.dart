import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/utils/video_preview_controller.dart';

class UploadVideoPreview extends StatefulWidget {
  const UploadVideoPreview({
    super.key,
    this.previewUrl,
    this.mobileFile,
  });

  final String? previewUrl;
  final XFile? mobileFile;

  @override
  State<UploadVideoPreview> createState() => _UploadVideoPreviewState();
}

class _UploadVideoPreviewState extends State<UploadVideoPreview> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(UploadVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewUrl != widget.previewUrl ||
        oldWidget.mobileFile != widget.mobileFile) {
      _disposeController();
      _load();
    }
  }

  Future<void> _load() async {
    final controller = await createUploadPreviewController(
      previewUrl: widget.previewUrl,
      mobileFile: widget.mobileFile,
    );
    if (controller == null || !mounted) {
      await controller?.dispose();
      return;
    }

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (_) {
      await controller.dispose();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _ready = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
