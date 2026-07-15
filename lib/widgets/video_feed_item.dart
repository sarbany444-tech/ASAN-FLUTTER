import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/content_policy.dart';
import '../../core/theme/app_colors.dart';
import '../../models/video_model.dart';
import '../../providers/feed_provider.dart';
import 'tiktok_video_player.dart';
import 'comments_sheet.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({
    super.key,
    required this.video,
    required this.isActive,
    this.currentUserId,
    this.onLike,
    this.onSave,
    this.onFollow,
    this.onReport,
    this.isFollowing = false,
  });

  final VideoModel video;
  final bool isActive;
  final String? currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onFollow;
  final VoidCallback? onReport;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        ContentPolicy.categoryLabels[video.category] ?? video.category;
    final isLiked =
        currentUserId != null && video.isLikedBy(currentUserId!);
    final isSaved =
        currentUserId != null && video.isSavedBy(currentUserId!);

    return Stack(
      fit: StackFit.expand,
      children: [
        TikTokVideoPlayer(video: video, isActive: isActive),
        Positioned(
          right: 10,
          bottom: 90,
          child: Column(
            children: [
              _AvatarAction(
                photoUrl: video.userPhotoUrl,
                name: video.userDisplayName,
                isVerified: video.isUserVerified,
                onTap: () => context.push('/user/${video.userId}'),
                showFollow: currentUserId != null && currentUserId != video.userId,
                isFollowing: isFollowing,
                onFollow: onFollow,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(video.likeCount),
                color: isLiked ? Colors.red : Colors.white,
                onTap: onLike,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.comment,
                label: _formatCount(video.commentCount),
                onTap: () => CommentsSheet.show(
                  context,
                  videoId: video.id,
                  videoOwnerId: video.userId,
                ),
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: _formatCount(video.saveCount),
                color: isSaved ? AppColors.accentGold : Colors.white,
                onTap: onSave,
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.share,
                label: _formatCount(video.shareCount),
                onTap: () async {
                  await Share.share('Watch on Naseem: ${video.title}');
                  if (context.mounted) {
                    context.read<FeedProvider>().incrementShare(video.id);
                  }
                },
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: onReport,
              ),
            ],
          ),
        ),
        Positioned(
          left: 14,
          right: 76,
          bottom: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/user/${video.userId}'),
                child: Row(
                  children: [
                    Text(
                      '@${video.userDisplayName.replaceAll(' ', '').toLowerCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    if (video.isUserVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: AppColors.accentGold, size: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              if (video.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ],
              if (video.hashtags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: video.hashtags.take(3).map((tag) {
                    return GestureDetector(
                      onTap: () => context.push('/hashtag/$tag'),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          color: AppColors.accentGoldLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                categoryLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Spinning disc animation (TikTok-style)
        Positioned(
          right: 10,
          bottom: 24,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 8),
              color: AppColors.primaryGreen,
            ),
            child: video.userPhotoUrl != null
                ? ClipOval(child: Image.network(video.userPhotoUrl!, fit: BoxFit.cover))
                : Center(
                    child: Text(
                      video.userDisplayName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, color: color, size: 32,
                shadows: const [Shadow(color: Colors.black45, blurRadius: 4)]),
          ),
          Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              )),
        ],
      ),
    );
  }
}

class _AvatarAction extends StatelessWidget {
  const _AvatarAction({
    this.photoUrl,
    required this.name,
    this.isVerified = false,
    this.onTap,
    this.showFollow = false,
    this.isFollowing = false,
    this.onFollow,
  });

  final String? photoUrl;
  final String name;
  final bool isVerified;
  final VoidCallback? onTap;
  final bool showFollow;
  final bool isFollowing;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accentGold,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                      : null,
                ),
              ),
              if (showFollow && !isFollowing)
                Positioned(
                  bottom: -8,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onFollow,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 14, color: AppColors.primaryGreenDark),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
