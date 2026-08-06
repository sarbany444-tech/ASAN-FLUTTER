/// Canonical ASAN Marketplace categories.
///
/// Monetization is category-agnostic: entitlements (personal/business,
/// verification, featured, premium) apply to every category through the same
/// engine. Adding a category only requires registering it here and optionally
/// seeding `config/categories/{id}` in Firestore — no monetization rewrite.
enum MarketplaceCategory {
  buyAndSell('buy_and_sell', 'Buy & Sell'),
  cars('cars', 'Cars'),
  realEstate('real_estate', 'Real Estate'),
  jobs('jobs', 'Jobs'),
  services('services', 'Services'),
  companies('companies', 'Companies'),
  shops('shops', 'Shops'),
  restaurants('restaurants', 'Restaurants'),
  hotels('hotels', 'Hotels'),
  doctors('doctors', 'Doctors'),
  teachers('teachers', 'Teachers'),
  courses('courses', 'Courses'),
  events('events', 'Events'),
  freelancers('freelancers', 'Freelancers');

  const MarketplaceCategory(this.id, this.label);

  final String id;
  final String label;

  static MarketplaceCategory? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    for (final c in MarketplaceCategory.values) {
      if (c.id == normalized || c.name.toLowerCase() == normalized) {
        return c;
      }
    }
    // Friendly aliases used in older UI copy.
    return switch (normalized) {
      'property' || 'realestate' => MarketplaceCategory.realEstate,
      'buy_sell' || 'buysell' || 'electronics' || 'clothing' || 'others' =>
        MarketplaceCategory.buyAndSell,
      'services_handymen' || 'handymen' => MarketplaceCategory.services,
      _ => null,
    };
  }

  static MarketplaceCategory parse(String value) =>
      tryParse(value) ?? MarketplaceCategory.buyAndSell;

  static List<MarketplaceCategory> get all => MarketplaceCategory.values;
}
