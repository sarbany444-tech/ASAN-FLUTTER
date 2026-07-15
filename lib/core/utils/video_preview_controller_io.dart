import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createUploadPreviewController({
  String? previewUrl,
  XFile? mobileFile,
}) async {
  if (previewUrl != null && previewUrl.isNotEmpty) {
    return VideoPlayerController.networkUrl(Uri.parse(previewUrl));
  }
  if (mobileFile != null && mobileFile.path.isNotEmpty) {
    return VideoPlayerController.file(File(mobileFile.path));
  }
  return null;
}
