import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/naseem_button.dart';
import '../../widgets/premium_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateProfile(
          displayName: _nameController.text.trim(),
          bio: _bioController.text.trim(),
        );
    if (mounted) {
      setState(() => _saving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: NaseemAppBar(
        title: l10n.editProfile,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppDecorations.purplePinkGradient,
                      boxShadow: AppDecorations.purpleGlow,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.navyCard,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to change photo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                PremiumGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: l10n.displayName,
                          prefixIcon:
                              const Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _bioController,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: l10n.bio,
                          prefixIcon: const Icon(Icons.notes_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NaseemButton(
                  label: l10n.save,
                  loading: _saving,
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
