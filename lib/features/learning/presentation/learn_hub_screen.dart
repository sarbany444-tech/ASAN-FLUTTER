import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/subject_catalog.dart' show SubjectCatalog, SubjectItem;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/learning_provider.dart';
import '../../../widgets/course_card.dart';
import '../../../widgets/premium_background.dart';
import '../../../widgets/premium_states.dart';

/// Unified learning hub: courses, languages, live classes, dashboards.
class LearnHubScreen extends StatefulWidget {
  const LearnHubScreen({super.key});

  @override
  State<LearnHubScreen> createState() => _LearnHubScreenState();
}

class _LearnHubScreenState extends State<LearnHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.navy.withValues(alpha: 0.85),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Learn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppDecorations.heroGradient,
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.school_outlined),
                  tooltip: 'My Learning',
                  onPressed: () => context.push('/student-dashboard'),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final items = _quickLinks(auth);
                    return _QuickLinkCard(item: items[index]);
                  },
                  childCount: _quickLinks(auth).length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'Grade 12 Subjects',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = SubjectCatalog.grade12Subjects[index];
                    return _SubjectCard(subject: subject);
                  },
                  childCount: SubjectCatalog.grade12Subjects.length,
                ),
              ),
            ),
            if (learning.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: PremiumLoading(message: 'Loading courses...'),
              )
            else if (learning.popularCourses.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text(
                    'Popular Courses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: learning.popularCourses.length,
                    itemBuilder: (_, i) {
                      final course = learning.popularCourses[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CourseCard(
                          course: course,
                          compact: true,
                          onTap: () => context.push('/course/${course.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<_QuickLink> _quickLinks(AuthProvider auth) => [
        _QuickLink('Courses', Icons.menu_book_rounded, '/courses',
            AppColors.primaryGreen),
        _QuickLink('Languages', Icons.language_rounded, '/languages',
            AppColors.cyan),
        _QuickLink('Live Classes', Icons.live_tv_rounded, '/live-classes',
            AppColors.pink),
        _QuickLink('Community', Icons.forum_outlined, '/community',
            AppColors.accentGold),
        if (auth.isTeacher)
          _QuickLink('Teacher Hub', Icons.dashboard_outlined,
              '/teacher-dashboard', AppColors.success),
        _QuickLink('Quizzes', Icons.quiz_outlined, '/quiz',
            AppColors.primaryGreenLight),
      ];
}

class _QuickLink {
  const _QuickLink(this.label, this.icon, this.route, this.color);
  final String label;
  final IconData icon;
  final String route;
  final Color color;
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.item});
  final _QuickLink item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        child: Ink(
          decoration: AppDecorations.glass(opacity: 0.65),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusMd),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const Spacer(),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final SubjectItem subject;

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.color);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/courses?subject=${subject.id}'),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(subject.icon, color: color, size: 22),
                const Spacer(),
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
