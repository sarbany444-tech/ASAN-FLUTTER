import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../features/creator/presentation/creator_verification_screen.dart';
import '../../models/enums.dart';
import '../../services/daily_content_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  final _verificationService = CreatorVerificationService();
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _adminService.getDashboardStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null || !user.role.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminDashboard)),
        body: const Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboard)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _StatCard('Users', '${_stats['users'] ?? 0}', Icons.people),
                      _StatCard('Videos', '${_stats['videos'] ?? 0}', Icons.video_library),
                      _StatCard('Pending Review', '${_stats['pendingModeration'] ?? 0}', Icons.pending),
                      _StatCard('Reports', '${_stats['pendingReports'] ?? 0}', Icons.flag),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Moderation Queue', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _adminService.getModerationQueue(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snapshot.data!;
                      if (items.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No pending items'),
                          ),
                        );
                      }
                      return Column(
                        children: items.map((item) {
                          return Card(
                            child: ListTile(
                              title: Text(item['title'] as String? ?? 'Video'),
                              subtitle: Text('Status: ${item['status']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: AppColors.success),
                                    onPressed: () => _adminService.approveVideo(
                                      item['videoId'] as String,
                                      user.uid,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppColors.error),
                                    onPressed: () => _adminService.rejectVideo(
                                      item['videoId'] as String,
                                      user.uid,
                                      'Policy violation',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Creator Verification',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _verificationService.pendingRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data!;
                      if (requests.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No pending verification requests'),
                          ),
                        );
                      }
                      return Column(
                        children: requests.map((req) {
                          final type = CreatorVerificationType.fromString(
                            req['creatorVerificationType'] as String?,
                          );
                          return Card(
                            child: ListTile(
                              title: Text(req['displayName'] as String? ?? 'User'),
                              subtitle: Text(type?.label ?? 'Creator'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: AppColors.success),
                                    onPressed: () => _verificationService
                                        .approveRequest(
                                      req['userId'] as String,
                                      user.uid,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: AppColors.error),
                                    onPressed: () => _verificationService
                                        .rejectRequest(
                                      req['userId'] as String,
                                      user.uid,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon);
  final String label;
  final String value;
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
            Icon(icon, color: AppColors.accentGold, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
