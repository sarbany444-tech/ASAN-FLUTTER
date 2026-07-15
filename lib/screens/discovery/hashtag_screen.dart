import 'package:flutter/material.dart';
import '../../services/discovery_service.dart';
import '../../widgets/video_thumbnail_card.dart';

class HashtagScreen extends StatelessWidget {
  const HashtagScreen({super.key, required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final service = DiscoveryService();

    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: FutureBuilder(
        future: service.getVideosByHashtag(tag),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = snap.data!;
          if (videos.isEmpty) {
            return Center(child: Text('No videos for #$tag'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: videos.length,
            itemBuilder: (_, i) => VideoThumbnailCard(video: videos[i]),
          );
        },
      ),
    );
  }
}
