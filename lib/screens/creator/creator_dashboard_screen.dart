import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/social_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/creator_analytics_service.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  final _analyticsService = CreatorAnalyticsService();
  CreatorAnalyticsModel? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final analytics = await _analyticsService.getAnalytics(user.uid);
    if (mounted) {
      setState(() {
        _analytics = analytics;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_analytics != null) ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _StatCard('Views', '${_analytics!.totalViews}', Icons.visibility),
                        _StatCard('Likes', '${_analytics!.totalLikes}', Icons.favorite),
                        _StatCard('Comments', '${_analytics!.totalComments}', Icons.comment),
                        _StatCard('Followers', '${_analytics!.totalFollowers}', Icons.people),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.verified, color: AppColors.accentGold),
                        title: const Text('Verified Islamic Creator'),
                        subtitle: const Text('Apply for verification through admin review'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon);
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentGold),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
