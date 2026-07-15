import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/social_provider.dart';
import '../../services/video_preload_manager.dart';
import '../../widgets/feed_tab_bar.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/video_feed_item.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _tabIndex = 1; // For You default
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFeed());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _pageController.dispose();
    VideoPreloadManager.instance.disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      VideoPreloadManager.instance.togglePlayPause();
    }
  }

  FeedType get _feedType => switch (_tabIndex) {
        0 => FeedType.following,
        1 => FeedType.forYou,
        _ => FeedType.trending,
      };

  Future<void> _loadFeed() async {
    final user = context.read<AuthProvider>().user;
    await context.read<FeedProvider>().loadFeed(
          type: _feedType,
          userId: user?.uid,
          followingIds: user?.followingIds ?? [],
        );
    _preloadAdjacent(0);
  }

  void _preloadAdjacent(int index) {
    final videos = context.read<FeedProvider>().videos;
    if (videos.isEmpty) return;
    VideoPreloadManager.instance.preloadAdjacent(
      videoIds: videos.map((v) => v.id).toList(),
      videoUrls: videos.map((v) => v.videoUrl).toList(),
      currentIndex: index,
    );
  }

  Future<void> _onPageChanged(int index) async {
    setState(() => _currentPage = index);
    context.read<FeedProvider>().setCurrentIndex(index);

    final videos = context.read<FeedProvider>().videos;
    if (index < videos.length) {
      await VideoPreloadManager.instance.setActive(videos[index].id);
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<FeedProvider>().recordView(user.uid, videos[index]);
      }
    }

    _preloadAdjacent(index);

    if (!mounted) return;
    // Infinite scroll — load more when near end
    if (index >= videos.length - 3) {
      final user = context.read<AuthProvider>().user;
      await context.read<FeedProvider>().loadMore(
            followingIds: user?.followingIds ?? [],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final user = context.watch<AuthProvider>().user;
    final videos = feed.videos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (feed.isLoading)
            const PremiumLoading(message: 'Loading feed…')
          else if (videos.isEmpty)
            _EmptyFeed(tabIndex: _tabIndex, onRefresh: _loadFeed)
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, index) {
                final video = videos[index];
                return VideoFeedItem(
                  video: video,
                  isActive: index == _currentPage,
                  currentUserId: user?.uid,
                  isFollowing: user?.followingIds.contains(video.userId) ?? false,
                  onLike: user != null
                      ? () => feed.toggleLike(video.id, user.uid)
                      : null,
                  onSave: user != null
                      ? () => feed.toggleSave(video.id, user.uid)
                      : null,
                  onFollow: user != null && user.uid != video.userId
                      ? () async {
                          await context.read<SocialProvider>().follow(
                                user.uid,
                                video.userId,
                                user.displayName,
                              );
                          setState(() {});
                        }
                      : null,
                  onReport: () => context.push('/report/${video.id}'),
                );
              },
            ),

          // Top bar — TikTok style
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.live_tv, color: Colors.white),
                  onPressed: () => context.push('/live'),
                ),
                Expanded(
                  child: FeedTabBar(
                    selectedIndex: _tabIndex,
                    onChanged: (i) {
                      setState(() {
                        _tabIndex = i;
                        _currentPage = 0;
                      });
                      _pageController.jumpToPage(0);
                      _loadFeed();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => context.push('/search'),
                ),
              ],
            ),
          ),

          if (feed.isLoadingMore)
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: PremiumLoading(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.tabIndex, required this.onRefresh});
  final int tabIndex;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final title = switch (tabIndex) {
      0 => 'Nothing from people you follow',
      2 => 'No trending videos yet',
      _ => 'No videos yet',
    };
    final subtitle = switch (tabIndex) {
      0 => 'Follow Islamic creators to see their content here',
      2 => 'Check back soon for trending Islamic content',
      _ => 'Be the first to share beneficial content!',
    };

    return PremiumEmptyState(
      title: title,
      subtitle: subtitle,
      icon: Icons.video_library_outlined,
      actionLabel: 'Refresh',
      onAction: onRefresh,
    );
  }
}
