import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../models/social_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/discovery_service.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/video_thumbnail_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late TabController _tabs;
  final _discovery = DiscoveryService();

  List<VideoModel> _videos = [];
  List<UserModel> _users = [];
  List<HashtagModel> _hashtags = [];
  List<UserModel> _recommendedCreators = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadRecommended();
  }

  Future<void> _loadRecommended() async {
    final userId = context.read<AuthProvider>().user?.uid ?? '';
    final creators = await _discovery.getRecommendedCreators(userId);
    final trending = await _discovery.getTrendingHashtags();
    setState(() {
      _recommendedCreators = creators;
      _hashtags = trending;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);

    final results = await Future.wait([
      _discovery.searchVideos(q),
      _discovery.searchUsers(q),
      _discovery.searchHashtags(q),
    ]);

    setState(() {
      _videos = results[0] as List<VideoModel>;
      _users = results[1] as List<UserModel>;
      _hashtags = results[2] as List<HashtagModel>;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: AppDecorations.glass(opacity: 0.85),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.textSecondary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Search videos, users, hashtags',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                onSubmitted: (_) => _search(),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                                child: const Icon(Icons.close_rounded,
                                    color: AppColors.textSecondary, size: 20),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppDecorations.brandGradient,
                          borderRadius:
                              BorderRadius.circular(AppDecorations.radiusMd),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: _search,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabs,
              indicatorColor: AppColors.accentGold,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Videos'),
                Tab(text: 'Users'),
                Tab(text: 'Hashtags'),
              ],
            ),
            Expanded(
              child: _searching
                  ? const PremiumLoading(message: 'Searching…')
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _videos.isEmpty
                            ? _TrendingSection(
                                title: 'Trending Islamic Content',
                                child: _recommendedCreators.isEmpty
                                    ? const PremiumEmptyState(
                                        title: 'Discover Islamic content',
                                        subtitle:
                                            'Search for videos, creators, or hashtags',
                                        icon: Icons.search_rounded,
                                      )
                                    : null,
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: _videos.length,
                                itemBuilder: (_, i) =>
                                    VideoThumbnailCard(video: _videos[i]),
                              ),
                        _users.isEmpty
                            ? _RecommendedCreatorsList(
                                creators: _recommendedCreators)
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _users.length,
                                itemBuilder: (_, i) {
                                  final u = _users[i];
                                  return _UserTile(user: u);
                                },
                              ),
                        _hashtags.isEmpty
                            ? PremiumEmptyState(
                                title: 'Explore hashtags',
                                subtitle: trendingHashtagsSubtitle(_hashtags),
                                icon: Icons.tag_rounded,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _hashtags.length,
                                itemBuilder: (_, i) {
                                  final h = _hashtags[i];
                                  return _HashtagTile(hashtag: h);
                                },
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String trendingHashtagsSubtitle(List<HashtagModel> tags) {
    if (tags.isEmpty) return 'Search for trending Islamic hashtags';
    return 'Try #${tags.first.tag} and more';
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppDecorations.glass(opacity: 0.78),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.displayName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white))
              : null,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified_rounded,
                  color: AppColors.accentGold, size: 16),
            ],
          ],
        ),
        subtitle: Text('${user.followerCount} followers',
            style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary),
        onTap: () => context.push('/user/${user.uid}'),
      ),
    );
  }
}

class _HashtagTile extends StatelessWidget {
  const _HashtagTile({required this.hashtag});
  final HashtagModel hashtag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppDecorations.glass(opacity: 0.78),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppDecorations.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
          ),
          child: const Icon(Icons.tag_rounded, color: Colors.white, size: 22),
        ),
        title: Text('#${hashtag.tag}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${hashtag.videoCount} videos',
            style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary),
        onTap: () => context.push('/hashtag/${hashtag.tag}'),
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  const _TrendingSection({required this.title, this.child});
  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(child: child ?? Text(title));
  }
}

class _RecommendedCreatorsList extends StatelessWidget {
  const _RecommendedCreatorsList({required this.creators});
  final List<UserModel> creators;

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return const PremiumEmptyState(
        title: 'No recommended creators',
        subtitle: 'Check back soon for Islamic creators to follow',
        icon: Icons.people_outline_rounded,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Text(
            'Recommended Islamic Creators',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ...creators.map((u) => _UserTile(user: u)),
      ],
    );
  }
}
