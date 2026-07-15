import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/daily_content_service.dart';

class ModeratorDashboardScreen extends StatelessWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final reportService = ReportService();
    final adminService = AdminService();

    if (user == null || !user.role.isModerator) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.moderatorDashboard)),
        body: const Center(child: Text('Access denied')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.moderatorDashboard),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reports'),
              Tab(text: 'Review Queue'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
              stream: reportService.getPendingReports(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!;
                if (reports.isEmpty) {
                  return const Center(child: Text('No pending reports'));
                }
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (_, i) {
                    final report = reports[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text('Video: ${report.videoId}'),
                        subtitle: Text('Reason: ${report.reason.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: adminService.getModerationQueue(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(child: Text('Queue empty'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(item['title'] as String? ?? 'Video'),
                        subtitle: const Text('Awaiting human review'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: AppColors.success),
                              onPressed: () => adminService.approveVideo(
                                item['videoId'] as String,
                                user.uid,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.error),
                              onPressed: () => adminService.rejectVideo(
                                item['videoId'] as String,
                                user.uid,
                                'Policy violation',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
