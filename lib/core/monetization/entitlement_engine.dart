import 'account_type.dart';
import 'marketplace_category.dart';
import 'monetization_config.dart';

/// Snapshot of a user's monetization-related state.
class MonetizationUserState {
  const MonetizationUserState({
    required this.userId,
    this.accountType = AccountType.personal,
    this.verificationStatus = VerificationStatus.none,
    this.planId = 'personal_free',
    this.activeListingCount = 0,
    this.featuredCredits = 0,
    this.interestedInBusiness = false,
    this.businessCategories = const [],
  });

  final String userId;
  final AccountType accountType;
  final VerificationStatus verificationStatus;
  final String planId;
  final int activeListingCount;
  final int featuredCredits;
  final bool interestedInBusiness;
  final List<String> businessCategories;

  factory MonetizationUserState.fromMap(
    String userId,
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return MonetizationUserState(userId: userId);
    }
    final categories = <String>[];
    final raw = data['businessCategories'] ??
        (data['businessProfile'] is Map
            ? (data['businessProfile'] as Map)['categories']
            : null);
    if (raw is List) {
      categories.addAll(raw.map((e) => e.toString()));
    }

    return MonetizationUserState(
      userId: userId,
      accountType: AccountType.parse(data['accountType'] as String?),
      verificationStatus:
          VerificationStatus.parse(data['verificationStatus'] as String?),
      planId: (data['planId'] as String?) ??
          (data['subscription'] is Map
              ? ((data['subscription'] as Map)['planId'] as String?)
              : null) ??
          'personal_free',
      activeListingCount: (data['activeListingCount'] as num?)?.toInt() ??
          (data['listingCount'] as num?)?.toInt() ??
          0,
      featuredCredits: (data['featuredCredits'] as num?)?.toInt() ?? 0,
      interestedInBusiness: data['interestedInBusiness'] == true,
      businessCategories: categories,
    );
  }
}

/// Decision returned by the entitlement engine — never throws for free users.
class EntitlementDecision {
  const EntitlementDecision.allow({this.reason = 'allowed'})
      : allowed = true,
        requiresPayment = false,
        isComingSoon = false;

  const EntitlementDecision.comingSoon({required this.reason})
      : allowed = true,
        requiresPayment = false,
        isComingSoon = true;

  const EntitlementDecision.deny({
    required this.reason,
    this.requiresPayment = false,
  })  : allowed = false,
        isComingSoon = false;

  final bool allowed;
  final bool requiresPayment;
  final bool isComingSoon;
  final String reason;
}

/// Category-agnostic entitlement checks.
///
/// Launch rule: if config is free / not enforcing payments, every personal and
/// business action that creates value for the user is allowed without friction.
class EntitlementEngine {
  const EntitlementEngine(this.config);

  final MonetizationConfig config;

  EntitlementDecision canCreateListing({
    required MonetizationUserState user,
    required MarketplaceCategory category,
  }) {
    final cat = config.categoryConfig(category);
    if (!cat.enabled) {
      return EntitlementDecision.deny(reason: 'Category is disabled');
    }

    // Launch / free campaign: never restrict first-time UX.
    if (config.isFullyFree) {
      return const EntitlementDecision.allow(reason: 'launch_free');
    }

    if (user.accountType == AccountType.personal && !cat.supportsPersonal) {
      return EntitlementDecision.deny(
        reason: 'Personal accounts cannot post in ${cat.label ?? category.label}',
      );
    }
    if (user.accountType == AccountType.business && !cat.supportsBusiness) {
      return EntitlementDecision.deny(
        reason: 'Business accounts cannot post in ${cat.label ?? category.label}',
      );
    }

    final max = _effectiveMaxListings(user, category);
    if (max >= 0 && user.activeListingCount >= max) {
      return EntitlementDecision.deny(
        reason: 'Listing limit reached ($max). Upgrade your plan to post more.',
        requiresPayment: config.subscriptionsEnabled,
      );
    }
    return const EntitlementDecision.allow();
  }

  EntitlementDecision canRequestVerification({
    required MonetizationUserState user,
    required MarketplaceCategory category,
  }) {
    final cat = config.categoryConfig(category);
    if (!cat.supportsVerification) {
      return EntitlementDecision.deny(
        reason: 'Verification is not available for this category',
      );
    }
    if (user.verificationStatus == VerificationStatus.verified) {
      return const EntitlementDecision.allow(reason: 'already_verified');
    }
    if (user.verificationStatus == VerificationStatus.pending) {
      return const EntitlementDecision.allow(reason: 'pending');
    }

    if (!config.isProductLive(RevenueProductType.verificationFee)) {
      // Free during launch — still allow the request; fee is zero.
      return const EntitlementDecision.comingSoon(
        reason: 'Verification is free during launch',
      );
    }
    return const EntitlementDecision.allow();
  }

  EntitlementDecision canFeatureListing({
    required MonetizationUserState user,
    required MarketplaceCategory category,
  }) {
    final cat = config.categoryConfig(category);
    if (!cat.supportsFeatured) {
      return EntitlementDecision.deny(
        reason: 'Featured listings are not available for this category',
      );
    }

    if (!config.isProductLive(RevenueProductType.featuredListing)) {
      return EntitlementDecision.comingSoon(
        reason: config.comingSoonMessage,
      );
    }

    if (user.featuredCredits > 0) {
      return const EntitlementDecision.allow(reason: 'credit');
    }
    return EntitlementDecision.allow(
      reason: 'payable',
    );
  }

  EntitlementDecision canUsePremiumServices({
    required MonetizationUserState user,
    required MarketplaceCategory category,
  }) {
    final cat = config.categoryConfig(category);
    if (!cat.supportsPremiumServices) {
      return EntitlementDecision.deny(
        reason: 'Premium services are not available for this category',
      );
    }
    if (!config.isProductLive(RevenueProductType.premiumService)) {
      return EntitlementDecision.comingSoon(
        reason: config.comingSoonMessage,
      );
    }
    final plan = config.plans[user.planId];
    if (plan?.includesPremiumServices == true) {
      return const EntitlementDecision.allow(reason: 'plan_includes');
    }
    return const EntitlementDecision.allow(reason: 'payable');
  }

  EntitlementDecision canSubscribeToBusinessPlan(String planId) {
    if (config.showBusinessPlansAsComingSoon) {
      return EntitlementDecision.comingSoon(
        reason: config.comingSoonMessage,
      );
    }
    final plan = config.plans[planId];
    if (plan == null || !plan.enabled) {
      return EntitlementDecision.deny(reason: 'Plan unavailable');
    }
    return const EntitlementDecision.allow();
  }

  int _effectiveMaxListings(
    MonetizationUserState user,
    MarketplaceCategory category,
  ) {
    final plan = config.plans[user.planId];
    if (plan != null && plan.maxActiveListings != 0) {
      // Prefer plan limit when subscriptions are live.
      if (config.subscriptionsEnabled) {
        final fromLimits = config.limits.maxListingsFor(
          accountType: user.accountType,
          category: category,
        );
        // Most restrictive positive limit wins; -1 = unlimited.
        if (plan.maxActiveListings < 0 && fromLimits < 0) return -1;
        if (plan.maxActiveListings < 0) return fromLimits;
        if (fromLimits < 0) return plan.maxActiveListings;
        return plan.maxActiveListings < fromLimits
            ? plan.maxActiveListings
            : fromLimits;
      }
    }
    return config.limits.maxListingsFor(
      accountType: user.accountType,
      category: category,
    );
  }
}
