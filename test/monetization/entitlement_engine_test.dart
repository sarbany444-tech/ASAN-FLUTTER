import 'package:asan/core/monetization/monetization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketplaceCategory', () {
    test('parses all canonical ids', () {
      for (final c in MarketplaceCategory.all) {
        expect(MarketplaceCategory.tryParse(c.id), c);
      }
    });

    test('supports friendly aliases', () {
      expect(MarketplaceCategory.tryParse('property'), MarketplaceCategory.realEstate);
      expect(MarketplaceCategory.tryParse('electronics'), MarketplaceCategory.buyAndSell);
      expect(MarketplaceCategory.tryParse('handymen'), MarketplaceCategory.services);
    });

    test('includes every required business category', () {
      final ids = MarketplaceCategory.all.map((c) => c.id).toSet();
      expect(
        ids,
        containsAll([
          'buy_and_sell',
          'cars',
          'real_estate',
          'jobs',
          'services',
          'companies',
          'shops',
          'restaurants',
          'hotels',
          'doctors',
          'teachers',
          'courses',
          'events',
          'freelancers',
        ]),
      );
    });
  });

  group('EntitlementEngine launch mode', () {
    late EntitlementEngine engine;
    late MonetizationUserState personal;

    setUp(() {
      engine = EntitlementEngine(MonetizationConfig.launchDefaults());
      personal = const MonetizationUserState(userId: 'u1');
    });

    test('allows listings in every category while free', () {
      for (final category in MarketplaceCategory.all) {
        final decision = engine.canCreateListing(
          user: personal,
          category: category,
        );
        // Companies/shops etc. still allow personal during launch when
        // category defaults supportPersonal=true; seed may tighten later.
        expect(decision.allowed, isTrue, reason: category.id);
      }
    });

    test('shows featured as coming soon', () {
      final d = engine.canFeatureListing(
        user: personal,
        category: MarketplaceCategory.cars,
      );
      expect(d.isComingSoon, isTrue);
      expect(d.allowed, isTrue);
    });

    test('business subscribe is coming soon', () {
      final d = engine.canSubscribeToBusinessPlan('business_pro');
      expect(d.isComingSoon, isTrue);
    });

    test('verification remains allowed (free) at launch', () {
      final d = engine.canRequestVerification(
        user: personal,
        category: MarketplaceCategory.doctors,
      );
      expect(d.allowed, isTrue);
    });
  });

  group('EntitlementEngine when payments enforced', () {
    test('enforces listing limits', () {
      const config = MonetizationConfig(
        launchMode: false,
        freeCampaignActive: false,
        paymentsEnforced: true,
        subscriptionsEnabled: true,
        limits: MonetizationLimits(personalMaxActiveListings: 2),
      );
      final engine = EntitlementEngine(config);
      const user = MonetizationUserState(
        userId: 'u1',
        activeListingCount: 2,
      );
      final d = engine.canCreateListing(
        user: user,
        category: MarketplaceCategory.buyAndSell,
      );
      expect(d.allowed, isFalse);
      expect(d.requiresPayment, isTrue);
    });

    test('allows subscribe when enabled', () {
      const config = MonetizationConfig(
        launchMode: false,
        freeCampaignActive: false,
        subscriptionsEnabled: true,
        paymentsEnforced: true,
        plans: BusinessPlan.defaultCatalog,
      );
      final engine = EntitlementEngine(config);
      final d = engine.canSubscribeToBusinessPlan('business_starter');
      expect(d.allowed, isTrue);
      expect(d.isComingSoon, isFalse);
    });
  });

  group('MonetizationConfig', () {
    test('fromMap preserves admin flags', () {
      final config = MonetizationConfig.fromMap({
        'launchMode': false,
        'freeCampaignActive': false,
        'subscriptionsEnabled': true,
        'paymentsEnforced': true,
        'currency': 'GBP',
        'pricing': {'verificationFee': 12.5},
        'limits': {'personalMaxActiveListings': 5},
      });
      expect(config.launchMode, isFalse);
      expect(config.freeCampaignActive, isFalse);
      expect(config.subscriptionsEnabled, isTrue);
      expect(config.currency, 'GBP');
      expect(config.pricing.verificationFee, 12.5);
      expect(config.limits.personalMaxActiveListings, 5);
      expect(config.isFullyFree, isFalse);
      expect(config.isProductLive(RevenueProductType.businessSubscription), isTrue);
    });

    test('missing doc falls back to free launch', () {
      final config = MonetizationConfig.fromMap(null);
      expect(config.isFullyFree, isTrue);
      expect(config.showBusinessPlansAsComingSoon, isTrue);
    });
  });
}
