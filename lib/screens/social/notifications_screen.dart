import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PremiumBackground(
          child: const PremiumEmptyState(
            title: 'Sign in required',
            subtitle: 'Log in to view your notifications',
            icon: Icons.lock_outline_rounded,
          ),
        ),
      );
    }

    final service = NotificationService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NaseemAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () => service.markAllAsRead(user.uid),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: PremiumBackground(
        child: StreamBuilder(
          stream: service.watchNotifications(user.uid),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const PremiumLoading(message: 'Loading notifications…');
            }
            final notifications = snap.data!;
            if (notifications.isEmpty) {
              return const PremiumEmptyState(
                title: 'No notifications yet',
                subtitle: 'Likes, comments, and follows will appear here',
                icon: Icons.notifications_none_rounded,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: AppDecorations.glass(
                    opacity: n.isRead ? 0.65 : 0.85,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusXl),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      backgroundImage: n.fromUserPhoto != null
                          ? NetworkImage(n.fromUserPhoto!)
                          : null,
                      child: n.fromUserPhoto == null
                          ? Icon(_iconForType(n.type),
                              color: Colors.white, size: 20)
                          : null,
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight:
                            n.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      n.body,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: n.createdAt != null
                        ? Text(
                            timeago.format(n.createdAt!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    onTap: () => service.markAsRead(n.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'like' => Icons.favorite_rounded,
      'comment' || 'reply' => Icons.comment_rounded,
      'follow' => Icons.person_add_rounded,
      'live' => Icons.live_tv_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}
