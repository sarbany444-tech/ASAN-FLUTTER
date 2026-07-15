import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learning_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<LearningProvider>().loadEnrollments(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppDecorations.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    size: 48, color: AppColors.primaryGreenDark),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                      Text(
                        'Track courses, quizzes, and certificates',
                        style: TextStyle(color: AppColors.primaryGreenDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Enrolled Courses'),
          if (learning.enrollments.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('No enrollments yet'),
                subtitle: const Text('Browse courses to get started'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/courses'),
              ),
            )
          else
            ...learning.enrollments.map(
              (e) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.book_outlined),
                  ),
                  title: Text('Course ${e.courseId}'),
                  subtitle: Text('${e.progress.toStringAsFixed(0)}% complete'),
                  trailing: CircularProgressIndicator(
                    value: e.progress / 100,
                    strokeWidth: 3,
                  ),
                  onTap: () => context.push('/course/${e.courseId}'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Achievements'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium_outlined,
                  color: AppColors.accentGold),
              title: Text('Certificates'),
              subtitle: Text('Earn certificates by completing courses'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.bookmark_outline),
              title: Text('Saved Lessons'),
              subtitle: Text('Access your bookmarked content'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
