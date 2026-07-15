import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/subject_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learning_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/section_header.dart';

class HomeLearningScreen extends StatefulWidget {
  const HomeLearningScreen({super.key});

  @override
  State<HomeLearningScreen> createState() => _HomeLearningScreenState();
}

class _HomeLearningScreenState extends State<HomeLearningScreen> {
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
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Naseem',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppDecorations.greenGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          if (learning.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            SliverToBoxAdapter(
              child: _WelcomeBanner(name: user?.displayName ?? 'Student'),
            ),
            if (learning.liveClasses.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Live Now'),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: learning.liveClasses.length,
                    itemBuilder: (_, i) {
                      final live = learning.liveClasses[i];
                      return _LiveChip(liveClass: live);
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Continue Learning'),
            ),
            SliverToBoxAdapter(
              child: _ContinueLearningCard(
                onTap: () => context.go('/courses'),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Grade 12 Subjects',
                actionLabel: 'See all',
                onAction: () => context.go('/courses'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = SubjectCatalog.grade12Subjects[index];
                    return _SubjectTile(
                      subject: subject,
                      onTap: () => context.push('/courses?subject=${subject.id}'),
                    );
                  },
                  childCount: SubjectCatalog.grade12Subjects.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Popular Courses'),
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
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppDecorations.goldGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGreenDark,
                      ),
                ),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryGreenDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn. Grow. Excel.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreenDark.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_stories_rounded,
            size: 48,
            color: AppColors.primaryGreenDark,
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject, required this.onTap});
  final SubjectItem subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(subject.color).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(subject.icon, color: Color(subject.color)),
              const Spacer(),
              Text(
                subject.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subject.grade,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
            child: const Icon(Icons.play_lesson_rounded,
                color: AppColors.primaryGreen),
          ),
          title: const Text('Pick up where you left off'),
          subtitle: const Text('Browse courses and start learning'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.liveClass});
  final dynamic liveClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text('LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
            ],
          ),
          const Spacer(),
          Text(
            liveClass.title as String,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
