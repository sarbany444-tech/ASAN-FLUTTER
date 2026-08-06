import 'account_type.dart';
import 'marketplace_category.dart';

/// Remote-controlled monetization configuration (Firestore `config/monetization`).
///
/// Admins flip flags and prices without shipping an app update. Launch defaults
/// keep the entire marketplace free and unrestricted.
class MonetizationConfig {
  const MonetizationConfig({
    this.subscriptionsEnabled = false,
    this.paymentsEnforced = false,
    this.advertisingEnabled = false,
    this.commissionsEnabled = false,
    this.inAppPaymentsEnabled = false,
    this.verificationFeesEnabled = false,
    this.featuredListingsEnabled = false,
    this.premiumServicesEnabled = false,
    this.promotionsEnabled = false,
    this.freeCampaignActive = true,
    this.launchMode = true,
    this.currency = 'EUR',
    this.comingSoonTitle = 'Business Plans',
    this.comingSoonMessage = 'Coming Soon — everything is free while we grow.',
    this.plans = const {},
    this.pricing = const MonetizationPricing(),
    this.limits = const MonetizationLimits(),
    this.categories = const {},
  });

  /// When false, UI shows plans as Coming Soon and never charges.
  final bool subscriptionsEnabled;

  /// When false, listing limits / paywalls are not enforced (launch strategy).
  final bool paymentsEnforced;

  final bool advertisingEnabled;
  final bool commissionsEnabled;
  final bool inAppPaymentsEnabled;
  final bool verificationFeesEnabled;
  final bool featuredListingsEnabled;
  final bool premiumServicesEnabled;
  final bool promotionsEnabled;

  /// Free campaign banner / zero pricing override.
  final bool freeCampaignActive;

  /// Convenience: launch mode = free everything, track interest only.
  final bool launchMode;

  final String currency;
  final String comingSoonTitle;
  final String comingSoonMessage;

  final Map<String, BusinessPlan> plans;
  final MonetizationPricing pricing;
  final MonetizationLimits limits;

  /// Per-category overrides keyed by [MarketplaceCategory.id].
  final Map<String, CategoryMonetization> categories;

  bool get isFullyFree =>
      launchMode || freeCampaignActive || !paymentsEnforced;

  bool get showBusinessPlansAsComingSoon =>
      !subscriptionsEnabled || launchMode;

  bool isProductLive(RevenueProductType type) {
    if (isFullyFree) return false;
    return switch (type) {
      RevenueProductType.businessSubscription => subscriptionsEnabled,
      RevenueProductType.featuredListing => featuredListingsEnabled,
      RevenueProductType.verificationFee => verificationFeesEnabled,
      RevenueProductType.advertising => advertisingEnabled,
      RevenueProductType.inAppPayment => inAppPaymentsEnabled,
      RevenueProductType.commission => commissionsEnabled,
      RevenueProductType.premiumService => premiumServicesEnabled,
    };
  }

  CategoryMonetization categoryConfig(MarketplaceCategory category) {
    return categories[category.id] ??
        CategoryMonetization.defaultsFor(category);
  }

  factory MonetizationConfig.launchDefaults() => MonetizationConfig(
        plans: BusinessPlan.defaultCatalog,
        categories: {
          for (final c in MarketplaceCategory.all)
            c.id: CategoryMonetization.defaultsFor(c),
        },
      );

  factory MonetizationConfig.fromMap(Map<String, dynamic>? data) {
    if (data == null) return MonetizationConfig.launchDefaults();

    final plansRaw = data['plans'];
    final plans = <String, BusinessPlan>{};
    if (plansRaw is Map) {
      for (final entry in plansRaw.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          plans[key] = BusinessPlan.fromMap(
            key,
            Map<String, dynamic>.from(value),
          );
        }
      }
    }

    final categoriesRaw = data['categories'];
    final categories = <String, CategoryMonetization>{};
    if (categoriesRaw is Map) {
      for (final entry in categoriesRaw.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          categories[key] = CategoryMonetization.fromMap(
            key,
            Map<String, dynamic>.from(value),
          );
        }
      }
    }

    return MonetizationConfig(
      subscriptionsEnabled: data['subscriptionsEnabled'] == true,
      paymentsEnforced: data['paymentsEnforced'] == true,
      advertisingEnabled: data['advertisingEnabled'] == true,
      commissionsEnabled: data['commissionsEnabled'] == true,
      inAppPaymentsEnabled: data['inAppPaymentsEnabled'] == true,
      verificationFeesEnabled: data['verificationFeesEnabled'] == true,
      featuredListingsEnabled: data['featuredListingsEnabled'] == true,
      premiumServicesEnabled: data['premiumServicesEnabled'] == true,
      promotionsEnabled: data['promotionsEnabled'] == true,
      freeCampaignActive: data['freeCampaignActive'] != false,
      launchMode: data['launchMode'] != false,
      currency: (data['currency'] as String?) ?? 'EUR',
      comingSoonTitle:
          (data['comingSoonTitle'] as String?) ?? 'Business Plans',
      comingSoonMessage: (data['comingSoonMessage'] as String?) ??
          'Coming Soon — everything is free while we grow.',
      plans: plans.isEmpty ? BusinessPlan.defaultCatalog : plans,
      pricing: MonetizationPricing.fromMap(
        data['pricing'] is Map
            ? Map<String, dynamic>.from(data['pricing'] as Map)
            : null,
      ),
      limits: MonetizationLimits.fromMap(
        data['limits'] is Map
            ? Map<String, dynamic>.from(data['limits'] as Map)
            : null,
      ),
      categories: categories.isEmpty
          ? {
              for (final c in MarketplaceCategory.all)
                c.id: CategoryMonetization.defaultsFor(c),
            }
          : categories,
    );
  }

  Map<String, dynamic> toMap() => {
        'subscriptionsEnabled': subscriptionsEnabled,
        'paymentsEnforced': paymentsEnforced,
        'advertisingEnabled': advertisingEnabled,
        'commissionsEnabled': commissionsEnabled,
        'inAppPaymentsEnabled': inAppPaymentsEnabled,
        'verificationFeesEnabled': verificationFeesEnabled,
        'featuredListingsEnabled': featuredListingsEnabled,
        'premiumServicesEnabled': premiumServicesEnabled,
        'promotionsEnabled': promotionsEnabled,
        'freeCampaignActive': freeCampaignActive,
        'launchMode': launchMode,
        'currency': currency,
        'comingSoonTitle': comingSoonTitle,
        'comingSoonMessage': comingSoonMessage,
        'plans': {for (final e in plans.entries) e.key: e.value.toMap()},
        'pricing': pricing.toMap(),
        'limits': limits.toMap(),
        'categories': {
          for (final e in categories.entries) e.key: e.value.toMap(),
        },
      };
}

class BusinessPlan {
  const BusinessPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.maxActiveListings,
    required this.includesVerification,
    required this.includesFeaturedCredits,
    required this.includesPremiumServices,
    this.description = '',
    this.featuredCreditsPerMonth = 0,
    this.sortOrder = 0,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String description;
  final double priceMonthly;
  final double priceYearly;
  final int maxActiveListings;
  final bool includesVerification;
  final bool includesFeaturedCredits;
  final int featuredCreditsPerMonth;
  final bool includesPremiumServices;
  final int sortOrder;
  final bool enabled;

  factory BusinessPlan.fromMap(String id, Map<String, dynamic> data) {
    return BusinessPlan(
      id: id,
      name: (data['name'] as String?) ?? id,
      description: (data['description'] as String?) ?? '',
      priceMonthly: (data['priceMonthly'] as num?)?.toDouble() ?? 0,
      priceYearly: (data['priceYearly'] as num?)?.toDouble() ?? 0,
      maxActiveListings: (data['maxActiveListings'] as num?)?.toInt() ?? -1,
      includesVerification: data['includesVerification'] == true,
      includesFeaturedCredits: data['includesFeaturedCredits'] == true,
      featuredCreditsPerMonth:
          (data['featuredCreditsPerMonth'] as num?)?.toInt() ?? 0,
      includesPremiumServices: data['includesPremiumServices'] == true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      enabled: data['enabled'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'priceMonthly': priceMonthly,
        'priceYearly': priceYearly,
        'maxActiveListings': maxActiveListings,
        'includesVerification': includesVerification,
        'includesFeaturedCredits': includesFeaturedCredits,
        'featuredCreditsPerMonth': featuredCreditsPerMonth,
        'includesPremiumServices': includesPremiumServices,
        'sortOrder': sortOrder,
        'enabled': enabled,
      };

  static const Map<String, BusinessPlan> defaultCatalog = {
    'personal_free': BusinessPlan(
      id: 'personal_free',
      name: 'Personal',
      description: 'Free forever for individuals.',
      priceMonthly: 0,
      priceYearly: 0,
      maxActiveListings: -1,
      includesVerification: false,
      includesFeaturedCredits: false,
      includesPremiumServices: false,
      sortOrder: 0,
    ),
    'business_starter': BusinessPlan(
      id: 'business_starter',
      name: 'Business Starter',
      description: 'For local shops and freelancers.',
      priceMonthly: 9.99,
      priceYearly: 99,
      maxActiveListings: 25,
      includesVerification: false,
      includesFeaturedCredits: true,
      featuredCreditsPerMonth: 2,
      includesPremiumServices: false,
      sortOrder: 1,
    ),
    'business_pro': BusinessPlan(
      id: 'business_pro',
      name: 'Business Pro',
      description: 'For growing companies across categories.',
      priceMonthly: 29.99,
      priceYearly: 299,
      maxActiveListings: 100,
      includesVerification: true,
      includesFeaturedCredits: true,
      featuredCreditsPerMonth: 10,
      includesPremiumServices: true,
      sortOrder: 2,
    ),
    'business_enterprise': BusinessPlan(
      id: 'business_enterprise',
      name: 'Enterprise',
      description: 'Unlimited reach for large operators.',
      priceMonthly: 99.99,
      priceYearly: 999,
      maxActiveListings: -1,
      includesVerification: true,
      includesFeaturedCredits: true,
      featuredCreditsPerMonth: 50,
      includesPremiumServices: true,
      sortOrder: 3,
    ),
  };
}

class MonetizationPricing {
  const MonetizationPricing({
    this.verificationFee = 0,
    this.featuredListingDaily = 0,
    this.featuredListingWeekly = 0,
    this.featuredListingMonthly = 0,
    this.premiumServiceBase = 0,
    this.advertisingCpm = 0,
    this.commissionRate = 0,
  });

  final double verificationFee;
  final double featuredListingDaily;
  final double featuredListingWeekly;
  final double featuredListingMonthly;
  final double premiumServiceBase;
  final double advertisingCpm;

  /// 0.0–1.0 fraction (e.g. 0.05 = 5%).
  final double commissionRate;

  factory MonetizationPricing.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const MonetizationPricing();
    return MonetizationPricing(
      verificationFee: (data['verificationFee'] as num?)?.toDouble() ?? 0,
      featuredListingDaily:
          (data['featuredListingDaily'] as num?)?.toDouble() ?? 0,
      featuredListingWeekly:
          (data['featuredListingWeekly'] as num?)?.toDouble() ?? 0,
      featuredListingMonthly:
          (data['featuredListingMonthly'] as num?)?.toDouble() ?? 0,
      premiumServiceBase:
          (data['premiumServiceBase'] as num?)?.toDouble() ?? 0,
      advertisingCpm: (data['advertisingCpm'] as num?)?.toDouble() ?? 0,
      commissionRate: (data['commissionRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'verificationFee': verificationFee,
        'featuredListingDaily': featuredListingDaily,
        'featuredListingWeekly': featuredListingWeekly,
        'featuredListingMonthly': featuredListingMonthly,
        'premiumServiceBase': premiumServiceBase,
        'advertisingCpm': advertisingCpm,
        'commissionRate': commissionRate,
      };
}

class MonetizationLimits {
  const MonetizationLimits({
    this.personalMaxActiveListings = -1,
    this.businessMaxActiveListings = -1,
    this.categoryOverrides = const {},
  });

  /// -1 means unlimited.
  final int personalMaxActiveListings;
  final int businessMaxActiveListings;

  /// categoryId → accountType → max listings
  final Map<String, Map<String, int>> categoryOverrides;

  int maxListingsFor({
    required AccountType accountType,
    MarketplaceCategory? category,
  }) {
    if (category != null) {
      final override = categoryOverrides[category.id]?[accountType.value];
      if (override != null) return override;
    }
    return accountType == AccountType.business
        ? businessMaxActiveListings
        : personalMaxActiveListings;
  }

  factory MonetizationLimits.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const MonetizationLimits();
    final overrides = <String, Map<String, int>>{};
    final raw = data['categoryOverrides'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final inner = <String, int>{};
        if (entry.value is Map) {
          for (final e in (entry.value as Map).entries) {
            final n = e.value;
            if (n is num) inner[e.key.toString()] = n.toInt();
          }
        }
        overrides[entry.key.toString()] = inner;
      }
    }
    return MonetizationLimits(
      personalMaxActiveListings:
          (data['personalMaxActiveListings'] as num?)?.toInt() ?? -1,
      businessMaxActiveListings:
          (data['businessMaxActiveListings'] as num?)?.toInt() ?? -1,
      categoryOverrides: overrides,
    );
  }

  Map<String, dynamic> toMap() => {
        'personalMaxActiveListings': personalMaxActiveListings,
        'businessMaxActiveListings': businessMaxActiveListings,
        'categoryOverrides': categoryOverrides,
      };
}

/// Per-category monetization capabilities (all true by default).
class CategoryMonetization {
  const CategoryMonetization({
    required this.categoryId,
    this.enabled = true,
    this.supportsPersonal = true,
    this.supportsBusiness = true,
    this.supportsVerification = true,
    this.supportsFeatured = true,
    this.supportsPremiumServices = true,
    this.label,
  });

  final String categoryId;
  final String? label;
  final bool enabled;
  final bool supportsPersonal;
  final bool supportsBusiness;
  final bool supportsVerification;
  final bool supportsFeatured;
  final bool supportsPremiumServices;

  factory CategoryMonetization.defaultsFor(MarketplaceCategory category) {
    return CategoryMonetization(
      categoryId: category.id,
      label: category.label,
    );
  }

  factory CategoryMonetization.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return CategoryMonetization(
      categoryId: id,
      label: data['label'] as String?,
      enabled: data['enabled'] != false,
      supportsPersonal: data['supportsPersonal'] != false,
      supportsBusiness: data['supportsBusiness'] != false,
      supportsVerification: data['supportsVerification'] != false,
      supportsFeatured: data['supportsFeatured'] != false,
      supportsPremiumServices: data['supportsPremiumServices'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'enabled': enabled,
        'supportsPersonal': supportsPersonal,
        'supportsBusiness': supportsBusiness,
        'supportsVerification': supportsVerification,
        'supportsFeatured': supportsFeatured,
        'supportsPremiumServices': supportsPremiumServices,
      };
}
