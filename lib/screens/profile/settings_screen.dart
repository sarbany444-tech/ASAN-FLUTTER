import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: NaseemAppBar(title: l10n.settings),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _SectionLabel(title: l10n.language),
            const SizedBox(height: 8),
            _GlassSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      _currentLanguage(context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                    ),
                  ),
                  RadioGroup<Locale>(
                    groupValue: context.watch<LocaleProvider>().locale,
                    onChanged: (locale) {
                      if (locale != null) {
                        context.read<LocaleProvider>().setLocale(locale);
                        if (locale.languageCode == 'en') {
                          context.read<AuthProvider>().updateProfile(
                                preferredLanguage: locale.languageCode,
                              );
                        }
                      }
                    },
                    child: Column(
                      children: [
                        _GlassRadioTile(
                          title: l10n.english,
                          value: const Locale('en'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _GlassRadioTile(
                          title: l10n.arabic,
                          value: const Locale('ar'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _GlassRadioTile(
                          title: l10n.kurdish,
                          value: const Locale('ku'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: 'Appearance'),
            const SizedBox(height: 8),
            _GlassSettingsCard(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: context.watch<ThemeProvider>().isDark,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (_) =>
                    context.read<ThemeProvider>().toggleDarkMode(),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: 'Legal'),
            const SizedBox(height: 8),
            _GlassSettingsCard(
              child: _GlassListTile(
                title: l10n.communityGuidelines,
                icon: Icons.gavel_rounded,
                onTap: () => context.push('/guidelines'),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: l10n.about),
            const SizedBox(height: 8),
            _AboutCard(l10n: l10n),
          ],
        ),
      ),
    );
  }

  String _currentLanguage(BuildContext context) {
    final code = context.watch<LocaleProvider>().locale.languageCode;
    return switch (code) {
      'ar' => 'العربية',
      'ku' => 'کوردی',
      _ => 'English',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _GlassSettingsCard extends StatelessWidget {
  const _GlassSettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glass(opacity: 0.65),
      child: child,
    );
  }
}

class _GlassRadioTile extends StatelessWidget {
  const _GlassRadioTile({
    required this.title,
    required this.value,
  });

  final String title;
  final Locale value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<Locale>(
      title: Text(title),
      value: value,
      activeColor: AppColors.primaryGreen,
    );
  }
}

class _GlassListTile extends StatelessWidget {
  const _GlassListTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppDecorations.heroGradient,
        borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        border: Border.all(color: AppColors.borderGlow),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppDecorations.brandGradient,
              boxShadow: AppDecorations.goldGlow,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Naseem',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.about,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: AppDecorations.glassPill(active: true),
            child: const Text(
              'v3.0.0',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appTagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
