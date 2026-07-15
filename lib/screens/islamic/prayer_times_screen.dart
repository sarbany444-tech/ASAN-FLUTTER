import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _service = PrayerTimesService();
  PrayerTimesData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getPrayerTimes();
      setState(() {
        _data = data;
        _loading = false;
        if (data == null) _error = 'Location unavailable';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _localizedPrayerName(String name, AppLocalizations l10n) {
    return switch (name) {
      'Fajr' => l10n.fajr,
      'Sunrise' => l10n.sunrise,
      'Dhuhr' => l10n.dhuhr,
      'Asr' => l10n.asr,
      'Maghrib' => l10n.maghrib,
      'Isha' => l10n.isha,
      _ => name,
    };
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.prayerTimes)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_data != null) ...[
                        Card(
                          color: AppColors.primaryGreen,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  l10n.nextPrayer,
                                  style: const TextStyle(color: AppColors.accentGold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _localizedPrayerName(
                                    _data!.nextPrayer.name,
                                    l10n,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  _formatTime(_data!.nextPrayer.time),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._data!.prayers.map(
                          (p) => Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.access_time,
                                color: p.name == _data!.nextPrayer.name
                                    ? AppColors.accentGold
                                    : AppColors.primaryGreen,
                              ),
                              title: Text(_localizedPrayerName(p.name, l10n)),
                              trailing: Text(
                                _formatTime(p.time),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
