import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../services/daily_content_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.videoId});

  final String videoId;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _reportService = ReportService();
  ReportReason _selectedReason = ReportReason.inappropriateContent;
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _submitting = true);
    await _reportService.submitReport(
      videoId: widget.videoId,
      reporterId: user.uid,
      reason: _selectedReason,
      description: _descriptionController.text.trim(),
    );
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportContent)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reportReason, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            RadioGroup<ReportReason>(
              groupValue: _selectedReason,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedReason = value);
                }
              },
              child: Column(
                children: ReportReason.values
                    .map(
                      (reason) => RadioListTile<ReportReason>(
                        title: Text(_reasonLabel(reason)),
                        value: reason,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: _submitting
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(l10n.submitReport),
            ),
          ],
        ),
      ),
    );
  }

  String _reasonLabel(ReportReason reason) {
    return switch (reason) {
      ReportReason.inappropriateContent => 'Inappropriate content',
      ReportReason.musicOrEntertainment => 'Music or entertainment',
      ReportReason.violence => 'Violence',
      ReportReason.hateSpeech => 'Hate speech',
      ReportReason.misinformation => 'Misinformation',
      ReportReason.spam => 'Spam',
      ReportReason.other => 'Other',
    };
  }
}
