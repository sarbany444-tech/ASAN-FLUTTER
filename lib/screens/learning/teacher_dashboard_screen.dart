import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashboardAction(
        icon: Icons.add_box_outlined,
        label: 'Create Course',
        color: AppColors.primaryGreen,
      ),
      _DashboardAction(
        icon: Icons.video_library_outlined,
        label: 'Upload Video',
        color: Colors.blue,
      ),
      _DashboardAction(
        icon: Icons.picture_as_pdf_outlined,
        label: 'Upload PDF',
        color: Colors.red,
      ),
      _DashboardAction(
        icon: Icons.quiz_outlined,
        label: 'Create Quiz',
        color: Colors.purple,
      ),
      _DashboardAction(
        icon: Icons.live_tv_rounded,
        label: 'Schedule Live',
        color: Colors.orange,
      ),
      _DashboardAction(
        icon: Icons.analytics_outlined,
        label: 'Analytics',
        color: Colors.teal,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppDecorations.greenGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teaching Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create courses, upload content, and reach students',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(label: 'Courses', value: '0'),
              const SizedBox(width: 12),
              _StatCard(label: 'Students', value: '0'),
              const SizedBox(width: 12),
              _StatCard(label: 'Live Classes', value: '0'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: actions
                .map(
                  (a) => Card(
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(a.icon, size: 32, color: a.color),
                          const SizedBox(height: 8),
                          Text(a.label,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
}
