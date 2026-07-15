import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class IslamicCalendarScreen extends StatelessWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hijri = HijriCalendar.now();
    final now = DateTime.now();

    final months = [
      'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.islamicCalendar)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: AppColors.primaryGreen,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      '${hijri.hDay} ${months[hijri.hMonth - 1]} ${hijri.hYear} AH',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_weekday(now.weekday)}, ${now.day}/${now.month}/${now.year}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _CalendarInfoRow(
              icon: Icons.nights_stay,
              label: 'Hijri Month',
              value: months[hijri.hMonth - 1],
            ),
            _CalendarInfoRow(
              icon: Icons.calendar_today,
              label: 'Hijri Year',
              value: '${hijri.hYear} AH',
            ),
            _CalendarInfoRow(
              icon: Icons.wb_sunny,
              label: 'Gregorian Date',
              value: '${now.day}/${now.month}/${now.year}',
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(int day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[day - 1];
  }
}

class _CalendarInfoRow extends StatelessWidget {
  const _CalendarInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
