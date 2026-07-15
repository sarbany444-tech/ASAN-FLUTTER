import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/moderation_result.dart';
import '../../services/daily_content_service.dart';

class DailyContentScreen extends StatefulWidget {
  const DailyContentScreen({super.key, required this.type});

  final String type;

  @override
  State<DailyContentScreen> createState() => _DailyContentScreenState();
}

class _DailyContentScreenState extends State<DailyContentScreen> {
  final _service = DailyContentService();
  DailyContentModel? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    DailyContentModel? content;
    switch (widget.type) {
      case 'quran':
        content = await _service.getDailyQuranVerse();
      case 'hadith':
        content = await _service.getDailyHadith();
      case 'reminder':
        content = await _service.getDailyReminder();
    }
    setState(() {
      _content = content;
      _loading = false;
    });
  }

  String _title(AppLocalizations l10n) {
    return switch (widget.type) {
      'quran' => l10n.dailyQuranVerse,
      'hadith' => l10n.dailyHadith,
      _ => l10n.reminders,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _content == null
              ? Center(child: Text(l10n.error))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen,
                              AppColors.primaryGreenDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _content!.arabicText,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    height: 1.8,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              height: 1,
                              color: AppColors.accentGold.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _content!.translation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_content!.reference != null)
                        ListTile(
                          leading: const Icon(Icons.bookmark,
                              color: AppColors.accentGold),
                          title: Text(_content!.reference!),
                          subtitle: _content!.source != null
                              ? Text(_content!.source!)
                              : null,
                        ),
                    ],
                  ),
                ),
    );
  }
}
