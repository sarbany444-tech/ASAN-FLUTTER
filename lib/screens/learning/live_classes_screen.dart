import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Classes')),
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
                  'Join Live Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Interactive classes with teachers in real time',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _LiveClassTile(
            title: 'Grade 12 Math - Exam Review',
            teacher: 'Dr. Ahmed Hassan',
            isLive: true,
          ),
          const _LiveClassTile(
            title: 'Physics - Electricity',
            teacher: 'Prof. Sara Ali',
            isLive: false,
            scheduled: 'Today, 4:00 PM',
          ),
          const SizedBox(height: 24),
          Text('Features', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Video streaming')),
              Chip(label: Text('Screen share')),
              Chip(label: Text('Whiteboard')),
              Chip(label: Text('Live chat')),
              Chip(label: Text('Q&A')),
              Chip(label: Text('Recordings')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Agora SDK / 100ms integration planned for production.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _LiveClassTile extends StatelessWidget {
  const _LiveClassTile({
    required this.title,
    required this.teacher,
    this.isLive = false,
    this.scheduled,
  });

  final String title;
  final String teacher;
  final bool isLive;
  final String? scheduled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLive ? Colors.red.shade100 : Colors.grey.shade200,
          child: Icon(
            isLive ? Icons.sensors : Icons.schedule,
            color: isLive ? Colors.red : Colors.grey,
          ),
        ),
        title: Text(title),
        subtitle: Text(isLive ? '$teacher · LIVE' : '$teacher · $scheduled'),
        trailing: isLive
            ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Join'),
              )
            : OutlinedButton(
                onPressed: () {},
                child: const Text('Remind'),
              ),
      ),
    );
  }
}
