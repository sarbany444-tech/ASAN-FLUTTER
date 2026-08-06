import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/monetization/monetization.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/marketplace_tracking_service.dart';
import '../../services/monetization_config_service.dart';

/// Admin controls for remote monetization flags & pricing.
/// Edits `config/monetization` — clients pick up changes without an app update.
class MonetizationAdminScreen extends StatefulWidget {
  const MonetizationAdminScreen({super.key});

  @override
  State<MonetizationAdminScreen> createState() =>
      _MonetizationAdminScreenState();
}

class _MonetizationAdminScreenState extends State<MonetizationAdminScreen> {
  final _configService = MonetizationConfigService();
  final _tracking = MarketplaceTrackingService();

  MonetizationConfig _config = MonetizationConfig.launchDefaults();
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await _configService.fetch();
    final stats = await _tracking.loadPlatformStats();
    if (!mounted) return;
    setState(() {
      _config = config;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    setState(() => _saving = true);
    try {
      await _configService.save(_config, updatedBy: user?.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monetization config saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _patch(MonetizationConfig Function(MonetizationConfig) update) {
    setState(() => _config = update(_config));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null || !user.role.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monetization Controls'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatsRow(stats: _stats),
                const SizedBox(height: 16),
                Text('Launch & gates', style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  title: const Text('Launch mode (everything free)'),
                  value: _config.launchMode,
                  onChanged: (v) => _patch((c) => _copy(c, launchMode: v)),
                ),
                SwitchListTile(
                  title: const Text('Free campaign active'),
                  value: _config.freeCampaignActive,
                  onChanged: (v) => _patch((c) => _copy(c, freeCampaignActive: v)),
                ),
                SwitchListTile(
                  title: const Text('Subscriptions enabled'),
                  value: _config.subscriptionsEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, subscriptionsEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Payments enforced (limits)'),
                  value: _config.paymentsEnforced,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, paymentsEnforced: v)),
                ),
                const Divider(),
                Text('Revenue modules', style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  title: const Text('Featured listings'),
                  value: _config.featuredListingsEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, featuredListingsEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Verification fees'),
                  value: _config.verificationFeesEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, verificationFeesEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Premium services'),
                  value: _config.premiumServicesEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, premiumServicesEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Advertising'),
                  value: _config.advertisingEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, advertisingEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Commissions'),
                  value: _config.commissionsEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, commissionsEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('In-app payments'),
                  value: _config.inAppPaymentsEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, inAppPaymentsEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Promotions'),
                  value: _config.promotionsEnabled,
                  onChanged: (v) =>
                      _patch((c) => _copy(c, promotionsEnabled: v)),
                ),
                const Divider(),
                Text('Pricing (${_config.currency})',
                    style: Theme.of(context).textTheme.titleMedium),
                _PriceField(
                  label: 'Verification fee',
                  value: _config.pricing.verificationFee,
                  onChanged: (v) => _patch(
                    (c) => _copy(
                      c,
                      pricing: MonetizationPricing(
                        verificationFee: v,
                        featuredListingDaily: c.pricing.featuredListingDaily,
                        featuredListingWeekly: c.pricing.featuredListingWeekly,
                        featuredListingMonthly: c.pricing.featuredListingMonthly,
                        premiumServiceBase: c.pricing.premiumServiceBase,
                        advertisingCpm: c.pricing.advertisingCpm,
                        commissionRate: c.pricing.commissionRate,
                      ),
                    ),
                  ),
                ),
                _PriceField(
                  label: 'Featured / day',
                  value: _config.pricing.featuredListingDaily,
                  onChanged: (v) => _patch(
                    (c) => _copy(
                      c,
                      pricing: MonetizationPricing(
                        verificationFee: c.pricing.verificationFee,
                        featuredListingDaily: v,
                        featuredListingWeekly: c.pricing.featuredListingWeekly,
                        featuredListingMonthly: c.pricing.featuredListingMonthly,
                        premiumServiceBase: c.pricing.premiumServiceBase,
                        advertisingCpm: c.pricing.advertisingCpm,
                        commissionRate: c.pricing.commissionRate,
                      ),
                    ),
                  ),
                ),
                _PriceField(
                  label: 'Featured / week',
                  value: _config.pricing.featuredListingWeekly,
                  onChanged: (v) => _patch(
                    (c) => _copy(
                      c,
                      pricing: MonetizationPricing(
                        verificationFee: c.pricing.verificationFee,
                        featuredListingDaily: c.pricing.featuredListingDaily,
                        featuredListingWeekly: v,
                        featuredListingMonthly: c.pricing.featuredListingMonthly,
                        premiumServiceBase: c.pricing.premiumServiceBase,
                        advertisingCpm: c.pricing.advertisingCpm,
                        commissionRate: c.pricing.commissionRate,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Text('Listing limits (-1 = unlimited)',
                    style: Theme.of(context).textTheme.titleMedium),
                _IntField(
                  label: 'Personal max active listings',
                  value: _config.limits.personalMaxActiveListings,
                  onChanged: (v) => _patch(
                    (c) => _copy(
                      c,
                      limits: MonetizationLimits(
                        personalMaxActiveListings: v,
                        businessMaxActiveListings:
                            c.limits.businessMaxActiveListings,
                        categoryOverrides: c.limits.categoryOverrides,
                      ),
                    ),
                  ),
                ),
                _IntField(
                  label: 'Business max active listings',
                  value: _config.limits.businessMaxActiveListings,
                  onChanged: (v) => _patch(
                    (c) => _copy(
                      c,
                      limits: MonetizationLimits(
                        personalMaxActiveListings:
                            c.limits.personalMaxActiveListings,
                        businessMaxActiveListings: v,
                        categoryOverrides: c.limits.categoryOverrides,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tip: keep launchMode=true until growth targets are met. '
                  'Flip subscriptionsEnabled from Firestore or this screen.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
    );
  }

  MonetizationConfig _copy(
    MonetizationConfig c, {
    bool? subscriptionsEnabled,
    bool? paymentsEnforced,
    bool? advertisingEnabled,
    bool? commissionsEnabled,
    bool? inAppPaymentsEnabled,
    bool? verificationFeesEnabled,
    bool? featuredListingsEnabled,
    bool? premiumServicesEnabled,
    bool? promotionsEnabled,
    bool? freeCampaignActive,
    bool? launchMode,
    MonetizationPricing? pricing,
    MonetizationLimits? limits,
  }) {
    return MonetizationConfig(
      subscriptionsEnabled: subscriptionsEnabled ?? c.subscriptionsEnabled,
      paymentsEnforced: paymentsEnforced ?? c.paymentsEnforced,
      advertisingEnabled: advertisingEnabled ?? c.advertisingEnabled,
      commissionsEnabled: commissionsEnabled ?? c.commissionsEnabled,
      inAppPaymentsEnabled: inAppPaymentsEnabled ?? c.inAppPaymentsEnabled,
      verificationFeesEnabled:
          verificationFeesEnabled ?? c.verificationFeesEnabled,
      featuredListingsEnabled:
          featuredListingsEnabled ?? c.featuredListingsEnabled,
      premiumServicesEnabled:
          premiumServicesEnabled ?? c.premiumServicesEnabled,
      promotionsEnabled: promotionsEnabled ?? c.promotionsEnabled,
      freeCampaignActive: freeCampaignActive ?? c.freeCampaignActive,
      launchMode: launchMode ?? c.launchMode,
      currency: c.currency,
      comingSoonTitle: c.comingSoonTitle,
      comingSoonMessage: c.comingSoonMessage,
      plans: c.plans,
      pricing: pricing ?? c.pricing,
      limits: limits ?? c.limits,
      categories: c.categories,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat('Business interest', '${stats['businessInterestCount'] ?? 0}'),
        const SizedBox(width: 8),
        _MiniStat('Business users', '${stats['businessUserCount'] ?? 0}'),
        const SizedBox(width: 8),
        _MiniStat('Listings', '${stats['totalListings'] ?? 0}'),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: value.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(isDense: true),
          onChanged: (s) {
            final v = double.tryParse(s);
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _IntField extends StatelessWidget {
  const _IntField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: '$value',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(isDense: true),
          onChanged: (s) {
            final v = int.tryParse(s);
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
