import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final _service = QiblaService();
  QiblaData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getQiblaDirection();
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qibla)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.locationPermission),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: Text(l10n.enableLocation),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryGreen,
                                  width: 3,
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: (_data!.compassRotation) * pi / 180,
                              child: Icon(
                                Icons.navigation,
                                size: 120,
                                color: AppColors.accentGold,
                              ),
                            ),
                            const Icon(Icons.circle, size: 12, color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '${_data!.qiblaBearing.toStringAsFixed(1)}°',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point your device toward the Qibla',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
    );
  }
}
