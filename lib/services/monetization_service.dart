import '../core/monetization/monetization.dart';
import 'marketplace_tracking_service.dart';
import 'monetization_config_service.dart';
import 'revenue_ledger_service.dart';

/// Facade for ASAN Marketplace monetization.
///
/// Category-agnostic: the same APIs work for Buy & Sell, Cars, Jobs, Hotels,
/// Doctors, etc. Billing is gated by Firebase `config/monetization` so launch
/// stays free and admin can enable products later without an app rewrite.
class MonetizationService {
  MonetizationService({
    MonetizationConfigService? configService,
    MarketplaceTrackingService? trackingService,
    RevenueLedgerService? ledgerService,
  })  : _configService = configService ?? MonetizationConfigService(),
        _tracking = trackingService ?? MarketplaceTrackingService(),
        _ledger = ledgerService ?? RevenueLedgerService();

  final MonetizationConfigService _configService;
  final MarketplaceTrackingService _tracking;
  final RevenueLedgerService _ledger;

  MonetizationConfig _config = MonetizationConfig.launchDefaults();
  MonetizationConfig get config => _config;

  EntitlementEngine get entitlements => EntitlementEngine(_config);

  Stream<MonetizationConfig> watchConfig() => _configService.watch();

  Future<MonetizationConfig> refreshConfig() async {
    _config = await _configService.fetch();
    return _config;
  }

  void applyConfig(MonetizationConfig config) => _config = config;

  Future<EntitlementDecision> checkCreateListing({
    required String userId,
    required MarketplaceCategory category,
  }) async {
    await refreshConfig();
    final user = await _tracking.loadUserState(userId);
    return entitlements.canCreateListing(user: user, category: category);
  }

  Future<void> onListingCreated({
    required String userId,
    required MarketplaceCategory category,
    String? listingId,
  }) {
    return _tracking.trackListingCreated(
      userId: userId,
      category: category,
      listingId: listingId,
    );
  }

  Future<void> expressBusinessInterest({
    required String userId,
    required List<MarketplaceCategory> categories,
    String? planId,
    bool convertToBusinessAccount = true,
  }) async {
    await _tracking.trackBusinessInterest(
      userId: userId,
      categoryIds: categories.map((c) => c.id).toList(),
      convertToBusinessAccount: convertToBusinessAccount,
    );
    if (planId != null) {
      await _ledger.recordBusinessPlanInterest(
        userId: userId,
        planId: planId,
        categoryId: categories.isEmpty ? null : categories.first.id,
      );
    }
  }

  Future<EntitlementDecision> checkSubscribe(String planId) async {
    await refreshConfig();
    return entitlements.canSubscribeToBusinessPlan(planId);
  }

  Future<EntitlementDecision> checkFeatureListing({
    required String userId,
    required MarketplaceCategory category,
  }) async {
    await refreshConfig();
    final user = await _tracking.loadUserState(userId);
    return entitlements.canFeatureListing(user: user, category: category);
  }

  Future<EntitlementDecision> checkVerification({
    required String userId,
    required MarketplaceCategory category,
  }) async {
    await refreshConfig();
    final user = await _tracking.loadUserState(userId);
    return entitlements.canRequestVerification(
      user: user,
      category: category,
    );
  }

  /// Records a future revenue event when a product becomes live.
  Future<String?> recordRevenue({
    required RevenueProductType type,
    required String userId,
    required double amount,
    String currency = 'EUR',
    String? categoryId,
    String? listingId,
    String? planId,
    String status = 'recorded',
    Map<String, dynamic>? metadata,
  }) {
    return _ledger.recordEvent(
      type: type,
      userId: userId,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      listingId: listingId,
      planId: planId,
      status: status,
      metadata: metadata,
    );
  }

  // ── Legacy Naseem-era APIs kept as no-op bridges (compat) ──────────────

  @Deprecated('Use expressBusinessInterest / revenue ledger instead')
  Future<void> recordDonation({
    required String donorId,
    required String creatorId,
    required double amount,
    required String type,
    String? message,
  }) async {
    await recordRevenue(
      type: RevenueProductType.inAppPayment,
      userId: donorId,
      amount: amount,
      status: 'legacy_donation',
      metadata: {
        'creatorId': creatorId,
        'donationType': type,
        'message': ?message,
      },
    );
  }

  @Deprecated('Use checkSubscribe / expressBusinessInterest instead')
  Future<void> subscribe({
    required String subscriberId,
    required String creatorId,
    required String tier,
  }) async {
    await expressBusinessInterest(
      userId: subscriberId,
      categories: const [],
      planId: tier,
      convertToBusinessAccount: true,
    );
  }

  @Deprecated('Use MarketplaceTrackingService.loadUserState instead')
  Future<bool> isSubscribed(String subscriberId, String creatorId) async {
    final user = await _tracking.loadUserState(subscriberId);
    return user.accountType == AccountType.business;
  }

  @Deprecated('Courses are a marketplace category — use listing flows')
  Future<List<Map<String, dynamic>>> getCourses({String? category}) async {
    return const [];
  }

  @Deprecated('Use RevenueLedgerService / analytics stats')
  Future<double> getCreatorRewardsBalance(String creatorId) async {
    return 0;
  }
}
