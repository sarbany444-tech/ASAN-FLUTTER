import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/video_thumbnail_card.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SocialProvider>().loadSavedVideos(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<SocialProvider>().savedVideos;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: const NaseemAppBar(title: 'Saved Videos'),
      body: PremiumBackground(
        child: videos.isEmpty
            ? const PremiumEmptyState(
                title: 'No saved videos',
                subtitle: 'Videos you bookmark will appear here',
                icon: Icons.bookmark_outline_rounded,
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: videos.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDecorations.radiusMd),
                  child: VideoThumbnailCard(video: videos[i]),
                ),
              ),
      ),
    );
  }
}

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SocialProvider>().loadWatchHistory(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<SocialProvider>().historyVideos;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: const NaseemAppBar(title: 'Watch History'),
      body: PremiumBackground(
        child: videos.isEmpty
            ? const PremiumEmptyState(
                title: 'No watch history',
                subtitle: 'Videos you watch will appear here',
                icon: Icons.history_rounded,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: videos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => Container(
                  decoration: AppDecorations.glass(opacity: 0.6),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusSm),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    title: Text(
                      videos[i].title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(videos[i].userDisplayName),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
