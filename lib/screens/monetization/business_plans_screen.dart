import 'package:flutter/material.dart';
import '../../core/monetization/monetization.dart';
import '../../services/monetization_service.dart';

/// Business plans surface — launch shows Coming Soon, never forces payment.
///
/// When admin enables `subscriptionsEnabled` in Firestore, the same screen
/// can present live plans without an architecture change.
class BusinessPlansScreen extends StatefulWidget {
  const BusinessPlansScreen({
    super.key,
    this.userId,
    this.accent = const Color(0xFFFFC83D),
    this.surface = const Color(0xFF0E1428),
    this.background = const Color(0xFF070B1A),
    this.onPrimary = const Color(0xFFF4F7FF),
    this.muted = const Color(0x8CF4F7FF),
  });

  final String? userId;
  final Color accent;
  final Color surface;
  final Color background;
  final Color onPrimary;
  final Color muted;

  @override
  State<BusinessPlansScreen> createState() => _BusinessPlansScreenState();
}

class _BusinessPlansScreenState extends State<BusinessPlansScreen> {
  final _service = MonetizationService();
  MonetizationConfig _config = MonetizationConfig.launchDefaults();
  final Set<MarketplaceCategory> _selected = {
    MarketplaceCategory.buyAndSell,
  };
  bool _loading = true;
  bool _submitting = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await _service.refreshConfig();
    if (!mounted) return;
    setState(() {
      _config = config;
      _loading = false;
    });
  }

  Future<void> _notifyInterest(BusinessPlan plan) async {
    final userId = widget.userId;
    setState(() => _submitting = true);
    try {
      if (userId != null && userId.isNotEmpty) {
        await _service.expressBusinessInterest(
          userId: userId,
          categories: _selected.toList(),
          planId: plan.id,
          convertToBusinessAccount: true,
        );
      }
      if (!mounted) return;
      setState(() {
        _statusMessage = _config.showBusinessPlansAsComingSoon
            ? 'Thanks! We saved your interest. Business plans are Coming Soon.'
            : 'Business account preference saved.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Could not save right now. You can keep using ASAN for free.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = _config.plans.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final comingSoon = _config.showBusinessPlansAsComingSoon;

    return Scaffold(
      backgroundColor: widget.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _config.comingSoonTitle,
          style: TextStyle(color: widget.onPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: widget.onPrimary),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: widget.accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _HeroBanner(
                  comingSoon: comingSoon,
                  title: comingSoon
                      ? '${_config.comingSoonTitle} — Coming Soon'
                      : 'Grow with ASAN Business',
                  message: comingSoon
                      ? _config.comingSoonMessage
                      : 'Choose a plan that fits every marketplace category.',
                  accent: widget.accent,
                  surface: widget.surface,
                  onPrimary: widget.onPrimary,
                  muted: widget.muted,
                ),
                const SizedBox(height: 20),
                Text(
                  'Works across every category',
                  style: TextStyle(
                    color: widget.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Personal (Free) · Business · Verification · Featured · Premium',
                  style: TextStyle(color: widget.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in MarketplaceCategory.all)
                      FilterChip(
                        label: Text(c.label),
                        selected: _selected.contains(c),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selected.add(c);
                            } else if (_selected.length > 1) {
                              _selected.remove(c);
                            }
                          });
                        },
                        selectedColor: widget.accent.withValues(alpha: 0.25),
                        checkmarkColor: widget.accent,
                        labelStyle: TextStyle(
                          color: _selected.contains(c)
                              ? widget.onPrimary
                              : widget.muted,
                          fontSize: 12,
                        ),
                        backgroundColor: widget.surface,
                        side: BorderSide(
                          color: widget.onPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Plans',
                  style: TextStyle(
                    color: widget.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                for (final plan in plans.where((p) => p.enabled)) ...[
                  _PlanCard(
                    plan: plan,
                    currency: _config.currency,
                    comingSoon: comingSoon,
                    accent: widget.accent,
                    surface: widget.surface,
                    onPrimary: widget.onPrimary,
                    muted: widget.muted,
                    busy: _submitting,
                    onSelect: () => _notifyInterest(plan),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage!,
                    style: TextStyle(color: widget.accent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Personal accounts stay free. No subscription is required to use ASAN.',
                  style: TextStyle(color: widget.muted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.comingSoon,
    required this.title,
    required this.message,
    required this.accent,
    required this.surface,
    required this.onPrimary,
    required this.muted,
  });

  final bool comingSoon;
  final String title;
  final String message;
  final Color accent;
  final Color surface;
  final Color onPrimary;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'COMING SOON',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          if (comingSoon) const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: muted, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.currency,
    required this.comingSoon,
    required this.accent,
    required this.surface,
    required this.onPrimary,
    required this.muted,
    required this.busy,
    required this.onSelect,
  });

  final BusinessPlan plan;
  final String currency;
  final bool comingSoon;
  final Color accent;
  final Color surface;
  final Color onPrimary;
  final Color muted;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final isFree = plan.priceMonthly <= 0;
    final priceLabel = isFree
        ? 'Free'
        : comingSoon
            ? 'From ${plan.priceMonthly.toStringAsFixed(2)} $currency/mo'
            : '${plan.priceMonthly.toStringAsFixed(2)} $currency/mo';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onPrimary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                priceLabel,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(plan.description, style: TextStyle(color: muted, fontSize: 13)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _FeatureTag(
                label: plan.maxActiveListings < 0
                    ? 'Unlimited listings'
                    : '${plan.maxActiveListings} listings',
                muted: muted,
              ),
              if (plan.includesVerification)
                _FeatureTag(label: 'Verification', muted: muted),
              if (plan.includesFeaturedCredits)
                _FeatureTag(
                  label: '${plan.featuredCreditsPerMonth} featured/mo',
                  muted: muted,
                ),
              if (plan.includesPremiumServices)
                _FeatureTag(label: 'Premium services', muted: muted),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : onSelect,
              style: FilledButton.styleFrom(
                backgroundColor: isFree ? accent : accent.withValues(alpha: 0.85),
                foregroundColor: const Color(0xFF070B1A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                comingSoon && !isFree
                    ? 'Notify me'
                    : isFree
                        ? 'Continue free'
                        : 'Select plan',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag({required this.label, required this.muted});
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: muted, fontSize: 11)),
    );
  }
}
