import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createUploadPreviewController({
  String? previewUrl,
  XFile? mobileFile,
}) async {
  if (previewUrl != null && previewUrl.isNotEmpty) {
    return VideoPlayerController.networkUrl(Uri.parse(previewUrl));
  }
  return null;
}
