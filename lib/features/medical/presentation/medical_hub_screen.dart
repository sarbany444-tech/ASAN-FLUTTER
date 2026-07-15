import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/medical_catalog.dart' show MedicalCatalog, MedicalCategory;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../models/enums.dart';
import '../../../widgets/naseem_app_bar.dart';
import '../../../widgets/naseem_button.dart';
import '../../../widgets/premium_background.dart';
import '../../../widgets/verified_badge.dart';

class MedicalHubScreen extends StatelessWidget {
  const MedicalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: NaseemAppBar(
        title: 'Medical Education',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search?type=medical'),
          ),
        ],
      ),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppDecorations.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
                boxShadow: AppDecorations.softShadow,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services_rounded,
                          color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Healthcare Education',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trusted content from verified doctors and nurses',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      MedicalCatalog.disclaimer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...MedicalCatalog.categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryTile(category: category),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Verified Creators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppDecorations.glass(opacity: 0.65),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: VerifiedBadge(
                      type: CreatorVerificationType.doctor,
                      compact: false,
                    ),
                  ),
                  Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: VerifiedBadge(
                      type: CreatorVerificationType.nurse,
                      compact: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NaseemButton(
              label: 'Apply for Medical Creator Verification',
              icon: Icons.verified_user_outlined,
              onPressed: () => context.push('/creator-verification'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final MedicalCategory category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/medical/${category.id}'),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        child: Ink(
          decoration: AppDecorations.glass(opacity: 0.65),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
              ),
              child: Icon(category.icon, color: color),
            ),
            title: Text(
              category.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(category.description),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
