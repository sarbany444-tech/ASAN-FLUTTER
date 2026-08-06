import 'package:asan/core/constants/marketplace_regions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketplaceRegions', () {
    test('covers Europe and Middle East', () {
      final regions =
          MarketplaceRegions.countries.map((c) => c.region).toSet();
      expect(regions, contains(MarketplaceRegionId.europe));
      expect(regions, contains(MarketplaceRegionId.middleEast));
    });

    test('includes core launch markets', () {
      final codes = MarketplaceRegions.countries.map((c) => c.code).toSet();
      expect(
        codes,
        containsAll([
          'GB',
          'DE',
          'FR',
          'IQ',
          'AE',
          'SA',
          'TR',
          'EG',
          'JO',
        ]),
      );
    });

    test('Iraq includes Kurdish cities', () {
      final iq = MarketplaceRegions.countryByCode('IQ')!;
      final cityIds = iq.cities.map((c) => c.id).toSet();
      expect(cityIds, containsAll(['erbil', 'sulaymaniyah', 'dohuk', 'baghdad']));
      expect(iq.currency.code, 'IQD');
    });

    test('country currency is applied when formatting', () {
      final ae = MarketplaceRegions.countryByCode('AE')!;
      expect(ae.currency.formatListing(1500), contains('1,500'));
      expect(ae.currency.code, 'AED');

      final gb = MarketplaceRegions.countryByCode('GB')!;
      expect(gb.currency.formatListing(425000), '£425,000');
    });

    test('every country has at least one city', () {
      for (final c in MarketplaceRegions.countries) {
        expect(c.cities, isNotEmpty, reason: c.code);
        expect(c.currency.code, isNotEmpty);
      }
    });

    test('byRegion filters correctly', () {
      final eu = MarketplaceRegions.byRegion(MarketplaceRegionId.europe);
      final me = MarketplaceRegions.byRegion(MarketplaceRegionId.middleEast);
      expect(eu.every((c) => c.region == MarketplaceRegionId.europe), isTrue);
      expect(me.every((c) => c.region == MarketplaceRegionId.middleEast), isTrue);
      expect(eu, isNotEmpty);
      expect(me, isNotEmpty);
    });
  });
}
