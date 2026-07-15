import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../services/video_service.dart';
import '../../widgets/video_thumbnail_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _videoService = VideoService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = context.read<AuthProvider>().user;
      if (me != null && me.uid != widget.userId) {
        context.read<SocialProvider>().checkFollowing(me.uid, widget.userId);
      }
    });
  }

  Future<void> _loadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(widget.userId)
        .get();
    if (doc.exists && mounted) {
      setState(() => _user = UserModel.fromMap(doc.data()!, widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final isFollowing = context.watch<SocialProvider>().isFollowing;
    final isOwnProfile = me?.uid == widget.userId;

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user!;

    return Scaffold(
      appBar: AppBar(title: Text(user.displayName)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryGreen,
                    backgroundImage:
                        user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? Text(user.displayName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 36, color: Colors.white))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (user.isVerified || user.role.isScholar) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: AppColors.accentGold),
                      ],
                    ],
                  ),
                  if (user.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(user.bio!, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat('${user.videoCount}', 'Videos'),
                      _ProfileStat('${user.followerCount}', 'Followers'),
                      _ProfileStat('${user.followingCount}', 'Following'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isOwnProfile && me != null)
                    ElevatedButton(
                      onPressed: () async {
                        if (isFollowing) {
                          await context
                              .read<SocialProvider>()
                              .unfollow(me.uid, widget.userId);
                        } else {
                          await context.read<SocialProvider>().follow(
                              me.uid, widget.userId, me.displayName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor:
                            isFollowing ? AppColors.offWhite : AppColors.primaryGreen,
                        foregroundColor:
                            isFollowing ? AppColors.textPrimary : Colors.white,
                      ),
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: _videoService.getUserVideos(widget.userId),
            builder: (context, snap) {
              final videos = snap.data ?? [];
              if (videos.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No videos yet')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => VideoThumbnailCard(video: videos[i]),
                    childCount: videos.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
