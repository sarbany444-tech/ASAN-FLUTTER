import 'dart:async';

import 'package:flutter/foundation.dart';
import '../core/monetization/monetization.dart';
import '../services/monetization_service.dart';

/// App-wide monetization state — listens to Firebase config for live admin
/// toggles (subscriptions, prices, limits) without requiring an app update.
class MonetizationProvider extends ChangeNotifier {
  MonetizationProvider({MonetizationService? service})
      : _service = service ?? MonetizationService();

  final MonetizationService _service;
  StreamSubscription<MonetizationConfig>? _sub;

  MonetizationConfig _config = MonetizationConfig.launchDefaults();
  bool _ready = false;

  MonetizationConfig get config => _config;
  bool get ready => _ready;
  bool get isFullyFree => _config.isFullyFree;
  bool get showBusinessPlansComingSoon =>
      _config.showBusinessPlansAsComingSoon;
  EntitlementEngine get entitlements => EntitlementEngine(_config);
  MonetizationService get service => _service;

  List<BusinessPlan> get visiblePlans {
    final plans = _config.plans.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return plans.where((p) => p.enabled).toList();
  }

  Future<void> init() async {
    _config = await _service.refreshConfig();
    _ready = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _service.watchConfig().listen((config) {
      _config = config;
      _service.applyConfig(config);
      _ready = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
