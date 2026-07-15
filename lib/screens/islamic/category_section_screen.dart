import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/content_policy.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/video_thumbnail_card.dart';

class CategorySectionScreen extends StatefulWidget {
  const CategorySectionScreen({super.key, required this.category});

  final String category;

  @override
  State<CategorySectionScreen> createState() => _CategorySectionScreenState();
}

class _CategorySectionScreenState extends State<CategorySectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().listenToCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label =
        ContentPolicy.categoryLabels[widget.category] ?? widget.category;
    final videos = context.watch<FeedProvider>().categoryVideos;

    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: videos.isEmpty
          ? Center(child: Text(l10n.noVideos))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: videos.length,
              itemBuilder: (_, i) => VideoThumbnailCard(video: videos[i]),
            ),
    );
  }
}
