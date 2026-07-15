import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/verified_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: PremiumBackground(
          child: PremiumEmptyState(
            title: l10n.login,
            subtitle: 'Sign in to view your profile',
            icon: Icons.person_outline_rounded,
            actionLabel: l10n.login,
            onAction: () => context.go('/login'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: NaseemAppBar(
        title: l10n.profile,
        transparent: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _ProfileHeader(user: user, l10n: l10n),
                const SizedBox(height: 24),
                PremiumGlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _StatColumn('0', 'Courses'),
                      const _StatDivider(),
                      const _StatColumn('0', 'Certificates'),
                      const _StatDivider(),
                      _StatColumn('${user.followerCount}', 'Following'),
                    ],
                  ),
                ),
                if (user.strikeCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusLg),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning),
                        const SizedBox(width: 10),
                        Text('${l10n.strikes}: ${user.strikeCount}'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      title: l10n.editProfile,
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _MenuItem(
                      icon: Icons.school_outlined,
                      title: 'My Learning',
                      onTap: () => context.push('/student-dashboard'),
                    ),
                    if (context.watch<AuthProvider>().isTeacher)
                      _MenuItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Teacher Dashboard',
                        onTap: () => context.push('/teacher-dashboard'),
                      ),
                    _MenuItem(
                      icon: Icons.forum_outlined,
                      title: 'Community',
                      onTap: () => context.push('/community'),
                    ),
                    _MenuItem(
                      icon: Icons.medical_services_outlined,
                      title: 'Medical Education',
                      onTap: () => context.push('/medical'),
                    ),
                    _MenuItem(
                      icon: Icons.mosque_outlined,
                      title: 'Islamic Hub',
                      onTap: () => context.push('/islamic-hub'),
                    ),
                    if (!user.isVerifiedCreator)
                      _MenuItem(
                        icon: Icons.verified_user_outlined,
                        title: 'Get Verified',
                        subtitle: 'Teacher, Scholar, Doctor, Nurse',
                        onTap: () => context.push('/creator-verification'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Saved',
                      onTap: () => context.push('/saved'),
                    ),
                    _MenuItem(
                      icon: Icons.history_rounded,
                      title: 'Watch History',
                      onTap: () => context.push('/history'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: l10n.notifications,
                      onTap: () => context.push('/notifications'),
                    ),
                    _MenuItem(
                      icon: Icons.message_outlined,
                      title: 'Messages',
                      onTap: () => context.push('/messages'),
                    ),
                    _MenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'Creator Dashboard',
                      onTap: () => context.push('/creator-dashboard'),
                    ),
                    _MenuItem(
                      icon: Icons.gavel_rounded,
                      title: l10n.communityGuidelines,
                      onTap: () => context.push('/guidelines'),
                    ),
                    if (user.role.isModerator)
                      _MenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: l10n.moderatorDashboard,
                        onTap: () => context.push('/moderator'),
                      ),
                    if (user.role.isAdmin)
                      _MenuItem(
                        icon: Icons.dashboard_outlined,
                        title: l10n.adminDashboard,
                        onTap: () => context.push('/admin'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      title: l10n.logout,
                      isDestructive: true,
                      onTap: () async {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.l10n});

  final UserModel user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppDecorations.purplePinkGradient,
            boxShadow: AppDecorations.purpleGlow,
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.navyCard,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (user.isVerified || user.role.isScholar) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified_rounded, color: AppColors.accentGold),
            ],
            if (user.isVerifiedCreator &&
                user.creatorVerificationType != null) ...[
              const SizedBox(width: 6),
              VerifiedBadge(
                type: user.creatorVerificationType!,
                compact: true,
              ),
            ],
          ],
        ),
        if (user.role.isScholar)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.verifiedScholar,
              style: const TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (user.bio != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.border,
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glass(opacity: 0.65),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _GlassMenuTile(item: items[i]),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 56, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _GlassMenuTile extends StatelessWidget {
  const _GlassMenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final color =
        item.isDestructive ? AppColors.error : AppColors.textPrimary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.isDestructive
              ? AppColors.error.withValues(alpha: 0.12)
              : AppColors.primaryGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        ),
        child: Icon(item.icon, color: color, size: 20),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: item.onTap,
    );
  }
}
