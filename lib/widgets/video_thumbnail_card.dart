import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/video_model.dart';

class VideoThumbnailCard extends StatelessWidget {
  const VideoThumbnailCard({super.key, required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryGreenDark,
              child: video.thumbnailUrl != null
                  ? Image.network(video.thumbnailUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(Icons.play_circle_outline,
                          size: 48, color: Colors.white54),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  video.userDisplayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
