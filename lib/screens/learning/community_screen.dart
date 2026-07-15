import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      ('How do I solve quadratic equations?', 'Student A', 5),
      ('Best resources for Grade 12 Physics?', 'Student B', 3),
      ('Tips for Arabic grammar exam', 'Student C', 8),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Ask Question'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            title: Text('Community'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Ask questions, share knowledge, and follow teachers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(post.$1),
                    subtitle: Text('${post.$2} · ${post.$3} answers'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
    );
  }
}
