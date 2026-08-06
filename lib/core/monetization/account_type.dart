/// Marketplace account tiers available to every category.
enum AccountType {
  /// Default free personal account — never paywalled at first launch.
  personal('personal'),

  /// Business account — tracked at launch; billing gated by admin flags.
  business('business');

  const AccountType(this.value);
  final String value;

  static AccountType parse(String? value) {
    final v = value?.toLowerCase().trim();
    if (v == AccountType.business.value) return AccountType.business;
    return AccountType.personal;
  }
}

/// Verification lifecycle for personal or business profiles.
enum VerificationStatus {
  none('none'),
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus parse(String? value) {
    for (final s in VerificationStatus.values) {
      if (s.value == value) return s;
    }
    return VerificationStatus.none;
  }
}

/// Modular revenue product types — enable independently via Firebase config.
enum RevenueProductType {
  businessSubscription('business_subscription'),
  featuredListing('featured_listing'),
  verificationFee('verification_fee'),
  advertising('advertising'),
  inAppPayment('in_app_payment'),
  commission('commission'),
  premiumService('premium_service');

  const RevenueProductType(this.value);
  final String value;

  static RevenueProductType? tryParse(String? value) {
    for (final t in RevenueProductType.values) {
      if (t.value == value) return t;
    }
    return null;
  }
}
