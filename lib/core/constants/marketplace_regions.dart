/// Europe & Middle East marketplace geography + currencies.
///
/// Used by create-listing and browse filters. Adding a country only requires
/// appending to [MarketplaceRegions.countries] — no monetization / UI rewrite.
library;

enum MarketplaceRegionId {
  europe('europe', 'Europe'),
  middleEast('middle_east', 'Middle East');

  const MarketplaceRegionId(this.id, this.label);
  final String id;
  final String label;
}

class MarketplaceCurrency {
  const MarketplaceCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimals = 2,
  });

  final String code;
  final String symbol;
  final String name;
  final int decimals;

  String format(num amount) {
    final fixed = amount.toStringAsFixed(decimals);
    // Most EU/ME currencies put the symbol before the amount in marketplace UX.
    return '$symbol$fixed';
  }

  String formatListing(num amount) => '$symbol${_group(amount)}';

  String _group(num amount) {
    final parts = amount.toStringAsFixed(decimals).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    if (decimals == 0) return whole;
    final frac = parts.length > 1 ? parts[1] : ''.padRight(decimals, '0');
    // Hide trailing .00 for whole amounts in classifieds.
    if (RegExp(r'^0+$').hasMatch(frac)) return whole;
    return '$whole.$frac';
  }
}

class MarketplaceCity {
  const MarketplaceCity({
    required this.id,
    required this.name,
    this.nameLocal,
  });

  final String id;
  final String name;
  final String? nameLocal;

  String get displayName =>
      nameLocal == null || nameLocal == name ? name : '$name ($nameLocal)';
}

class MarketplaceCountry {
  const MarketplaceCountry({
    required this.code,
    required this.name,
    required this.region,
    required this.currency,
    required this.cities,
    this.nameLocal,
    this.enabled = true,
  });

  final String code; // ISO 3166-1 alpha-2
  final String name;
  final String? nameLocal;
  final MarketplaceRegionId region;
  final MarketplaceCurrency currency;
  final List<MarketplaceCity> cities;
  final bool enabled;

  String get displayName =>
      nameLocal == null || nameLocal == name ? name : '$name ($nameLocal)';

  String locationLabel(MarketplaceCity city) => '${city.name}, $name';
}

/// Canonical catalog for ASAN Marketplace coverage.
abstract final class MarketplaceRegions {
  MarketplaceRegions._();

  // ── Currencies ────────────────────────────────────────────────────────────

  static const eur = MarketplaceCurrency(code: 'EUR', symbol: '€', name: 'Euro');
  static const gbp =
      MarketplaceCurrency(code: 'GBP', symbol: '£', name: 'British Pound');
  static const chf =
      MarketplaceCurrency(code: 'CHF', symbol: 'CHF ', name: 'Swiss Franc');
  static const sek =
      MarketplaceCurrency(code: 'SEK', symbol: 'kr', name: 'Swedish Krona');
  static const nok =
      MarketplaceCurrency(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone');
  static const dkk =
      MarketplaceCurrency(code: 'DKK', symbol: 'kr', name: 'Danish Krone');
  static const pln =
      MarketplaceCurrency(code: 'PLN', symbol: 'zł', name: 'Polish Zloty');
  static const czk =
      MarketplaceCurrency(code: 'CZK', symbol: 'Kč', name: 'Czech Koruna');
  static const ron =
      MarketplaceCurrency(code: 'RON', symbol: 'lei', name: 'Romanian Leu');
  static const huf = MarketplaceCurrency(
    code: 'HUF',
    symbol: 'Ft',
    name: 'Hungarian Forint',
    decimals: 0,
  );
  static const tryCurrency =
      MarketplaceCurrency(code: 'TRY', symbol: '₺', name: 'Turkish Lira');
  static const aed = MarketplaceCurrency(
    code: 'AED',
    symbol: 'AED ',
    name: 'UAE Dirham',
  );
  static const sar = MarketplaceCurrency(
    code: 'SAR',
    symbol: 'SAR ',
    name: 'Saudi Riyal',
  );
  static const iqd = MarketplaceCurrency(
    code: 'IQD',
    symbol: 'IQD ',
    name: 'Iraqi Dinar',
    decimals: 0,
  );
  static const kwd = MarketplaceCurrency(
    code: 'KWD',
    symbol: 'KD ',
    name: 'Kuwaiti Dinar',
    decimals: 3,
  );
  static const qar = MarketplaceCurrency(
    code: 'QAR',
    symbol: 'QAR ',
    name: 'Qatari Riyal',
  );
  static const bhd = MarketplaceCurrency(
    code: 'BHD',
    symbol: 'BD ',
    name: 'Bahraini Dinar',
    decimals: 3,
  );
  static const omr = MarketplaceCurrency(
    code: 'OMR',
    symbol: 'OMR ',
    name: 'Omani Rial',
    decimals: 3,
  );
  static const jod = MarketplaceCurrency(
    code: 'JOD',
    symbol: 'JD ',
    name: 'Jordanian Dinar',
    decimals: 3,
  );
  static const lbp = MarketplaceCurrency(
    code: 'LBP',
    symbol: 'LBP ',
    name: 'Lebanese Pound',
    decimals: 0,
  );
  static const egp =
      MarketplaceCurrency(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound');

  static const List<MarketplaceCurrency> currencies = [
    eur,
    gbp,
    chf,
    sek,
    nok,
    dkk,
    pln,
    czk,
    ron,
    huf,
    tryCurrency,
    aed,
    sar,
    iqd,
    kwd,
    qar,
    bhd,
    omr,
    jod,
    lbp,
    egp,
  ];

  // ── Countries ─────────────────────────────────────────────────────────────

  static const List<MarketplaceCountry> countries = [
    // Europe
    MarketplaceCountry(
      code: 'GB',
      name: 'United Kingdom',
      region: MarketplaceRegionId.europe,
      currency: gbp,
      cities: [
        MarketplaceCity(id: 'london', name: 'London'),
        MarketplaceCity(id: 'manchester', name: 'Manchester'),
        MarketplaceCity(id: 'birmingham', name: 'Birmingham'),
        MarketplaceCity(id: 'leeds', name: 'Leeds'),
        MarketplaceCity(id: 'glasgow', name: 'Glasgow'),
        MarketplaceCity(id: 'edinburgh', name: 'Edinburgh'),
        MarketplaceCity(id: 'cardiff', name: 'Cardiff'),
        MarketplaceCity(id: 'belfast', name: 'Belfast'),
        MarketplaceCity(id: 'liverpool', name: 'Liverpool'),
        MarketplaceCity(id: 'bristol', name: 'Bristol'),
      ],
    ),
    MarketplaceCountry(
      code: 'DE',
      name: 'Germany',
      nameLocal: 'Deutschland',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'berlin', name: 'Berlin'),
        MarketplaceCity(id: 'munich', name: 'Munich', nameLocal: 'München'),
        MarketplaceCity(id: 'hamburg', name: 'Hamburg'),
        MarketplaceCity(id: 'frankfurt', name: 'Frankfurt'),
        MarketplaceCity(id: 'cologne', name: 'Cologne', nameLocal: 'Köln'),
        MarketplaceCity(id: 'stuttgart', name: 'Stuttgart'),
        MarketplaceCity(id: 'dusseldorf', name: 'Düsseldorf'),
      ],
    ),
    MarketplaceCountry(
      code: 'FR',
      name: 'France',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'paris', name: 'Paris'),
        MarketplaceCity(id: 'lyon', name: 'Lyon'),
        MarketplaceCity(id: 'marseille', name: 'Marseille'),
        MarketplaceCity(id: 'lille', name: 'Lille'),
        MarketplaceCity(id: 'toulouse', name: 'Toulouse'),
        MarketplaceCity(id: 'nice', name: 'Nice'),
      ],
    ),
    MarketplaceCountry(
      code: 'NL',
      name: 'Netherlands',
      nameLocal: 'Nederland',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'amsterdam', name: 'Amsterdam'),
        MarketplaceCity(id: 'rotterdam', name: 'Rotterdam'),
        MarketplaceCity(id: 'the_hague', name: 'The Hague', nameLocal: 'Den Haag'),
        MarketplaceCity(id: 'utrecht', name: 'Utrecht'),
      ],
    ),
    MarketplaceCountry(
      code: 'BE',
      name: 'Belgium',
      nameLocal: 'België',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'brussels', name: 'Brussels', nameLocal: 'Bruxelles'),
        MarketplaceCity(id: 'antwerp', name: 'Antwerp', nameLocal: 'Antwerpen'),
        MarketplaceCity(id: 'ghent', name: 'Ghent', nameLocal: 'Gent'),
      ],
    ),
    MarketplaceCountry(
      code: 'ES',
      name: 'Spain',
      nameLocal: 'España',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'madrid', name: 'Madrid'),
        MarketplaceCity(id: 'barcelona', name: 'Barcelona'),
        MarketplaceCity(id: 'valencia', name: 'Valencia'),
        MarketplaceCity(id: 'seville', name: 'Seville', nameLocal: 'Sevilla'),
      ],
    ),
    MarketplaceCountry(
      code: 'IT',
      name: 'Italy',
      nameLocal: 'Italia',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'rome', name: 'Rome', nameLocal: 'Roma'),
        MarketplaceCity(id: 'milan', name: 'Milan', nameLocal: 'Milano'),
        MarketplaceCity(id: 'naples', name: 'Naples', nameLocal: 'Napoli'),
        MarketplaceCity(id: 'turin', name: 'Turin', nameLocal: 'Torino'),
      ],
    ),
    MarketplaceCountry(
      code: 'IE',
      name: 'Ireland',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'dublin', name: 'Dublin'),
        MarketplaceCity(id: 'cork', name: 'Cork'),
        MarketplaceCity(id: 'galway', name: 'Galway'),
      ],
    ),
    MarketplaceCountry(
      code: 'AT',
      name: 'Austria',
      nameLocal: 'Österreich',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'vienna', name: 'Vienna', nameLocal: 'Wien'),
        MarketplaceCity(id: 'graz', name: 'Graz'),
        MarketplaceCity(id: 'salzburg', name: 'Salzburg'),
      ],
    ),
    MarketplaceCountry(
      code: 'PT',
      name: 'Portugal',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'lisbon', name: 'Lisbon', nameLocal: 'Lisboa'),
        MarketplaceCity(id: 'porto', name: 'Porto'),
      ],
    ),
    MarketplaceCountry(
      code: 'GR',
      name: 'Greece',
      nameLocal: 'Ελλάδα',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'athens', name: 'Athens', nameLocal: 'Αθήνα'),
        MarketplaceCity(id: 'thessaloniki', name: 'Thessaloniki'),
      ],
    ),
    MarketplaceCountry(
      code: 'FI',
      name: 'Finland',
      nameLocal: 'Suomi',
      region: MarketplaceRegionId.europe,
      currency: eur,
      cities: [
        MarketplaceCity(id: 'helsinki', name: 'Helsinki'),
        MarketplaceCity(id: 'tampere', name: 'Tampere'),
      ],
    ),
    MarketplaceCountry(
      code: 'SE',
      name: 'Sweden',
      nameLocal: 'Sverige',
      region: MarketplaceRegionId.europe,
      currency: sek,
      cities: [
        MarketplaceCity(id: 'stockholm', name: 'Stockholm'),
        MarketplaceCity(id: 'gothenburg', name: 'Gothenburg', nameLocal: 'Göteborg'),
        MarketplaceCity(id: 'malmo', name: 'Malmö'),
      ],
    ),
    MarketplaceCountry(
      code: 'NO',
      name: 'Norway',
      nameLocal: 'Norge',
      region: MarketplaceRegionId.europe,
      currency: nok,
      cities: [
        MarketplaceCity(id: 'oslo', name: 'Oslo'),
        MarketplaceCity(id: 'bergen', name: 'Bergen'),
      ],
    ),
    MarketplaceCountry(
      code: 'DK',
      name: 'Denmark',
      nameLocal: 'Danmark',
      region: MarketplaceRegionId.europe,
      currency: dkk,
      cities: [
        MarketplaceCity(id: 'copenhagen', name: 'Copenhagen', nameLocal: 'København'),
        MarketplaceCity(id: 'aarhus', name: 'Aarhus'),
      ],
    ),
    MarketplaceCountry(
      code: 'CH',
      name: 'Switzerland',
      nameLocal: 'Schweiz',
      region: MarketplaceRegionId.europe,
      currency: chf,
      cities: [
        MarketplaceCity(id: 'zurich', name: 'Zurich', nameLocal: 'Zürich'),
        MarketplaceCity(id: 'geneva', name: 'Geneva', nameLocal: 'Genève'),
        MarketplaceCity(id: 'basel', name: 'Basel'),
      ],
    ),
    MarketplaceCountry(
      code: 'PL',
      name: 'Poland',
      nameLocal: 'Polska',
      region: MarketplaceRegionId.europe,
      currency: pln,
      cities: [
        MarketplaceCity(id: 'warsaw', name: 'Warsaw', nameLocal: 'Warszawa'),
        MarketplaceCity(id: 'krakow', name: 'Kraków'),
        MarketplaceCity(id: 'wroclaw', name: 'Wrocław'),
        MarketplaceCity(id: 'gdansk', name: 'Gdańsk'),
      ],
    ),
    MarketplaceCountry(
      code: 'CZ',
      name: 'Czechia',
      nameLocal: 'Česko',
      region: MarketplaceRegionId.europe,
      currency: czk,
      cities: [
        MarketplaceCity(id: 'prague', name: 'Prague', nameLocal: 'Praha'),
        MarketplaceCity(id: 'brno', name: 'Brno'),
      ],
    ),
    MarketplaceCountry(
      code: 'RO',
      name: 'Romania',
      nameLocal: 'România',
      region: MarketplaceRegionId.europe,
      currency: ron,
      cities: [
        MarketplaceCity(id: 'bucharest', name: 'Bucharest', nameLocal: 'București'),
        MarketplaceCity(id: 'cluj', name: 'Cluj-Napoca'),
      ],
    ),
    MarketplaceCountry(
      code: 'HU',
      name: 'Hungary',
      nameLocal: 'Magyarország',
      region: MarketplaceRegionId.europe,
      currency: huf,
      cities: [
        MarketplaceCity(id: 'budapest', name: 'Budapest'),
        MarketplaceCity(id: 'debrecen', name: 'Debrecen'),
      ],
    ),

    // Middle East
    MarketplaceCountry(
      code: 'IQ',
      name: 'Iraq',
      nameLocal: 'العراق',
      region: MarketplaceRegionId.middleEast,
      currency: iqd,
      cities: [
        MarketplaceCity(id: 'baghdad', name: 'Baghdad', nameLocal: 'بغداد'),
        MarketplaceCity(id: 'erbil', name: 'Erbil', nameLocal: 'هەولێر'),
        MarketplaceCity(
          id: 'sulaymaniyah',
          name: 'Sulaymaniyah',
          nameLocal: 'سلێمانی',
        ),
        MarketplaceCity(id: 'basra', name: 'Basra', nameLocal: 'البصرة'),
        MarketplaceCity(id: 'mosul', name: 'Mosul', nameLocal: 'الموصل'),
        MarketplaceCity(id: 'dohuk', name: 'Dohuk', nameLocal: 'دهۆک'),
        MarketplaceCity(id: 'kirkuk', name: 'Kirkuk', nameLocal: 'کەرکووک'),
        MarketplaceCity(id: 'najaf', name: 'Najaf', nameLocal: 'النجف'),
      ],
    ),
    MarketplaceCountry(
      code: 'AE',
      name: 'United Arab Emirates',
      nameLocal: 'الإمارات',
      region: MarketplaceRegionId.middleEast,
      currency: aed,
      cities: [
        MarketplaceCity(id: 'dubai', name: 'Dubai', nameLocal: 'دبي'),
        MarketplaceCity(id: 'abu_dhabi', name: 'Abu Dhabi', nameLocal: 'أبوظبي'),
        MarketplaceCity(id: 'sharjah', name: 'Sharjah', nameLocal: 'الشارقة'),
        MarketplaceCity(id: 'ajman', name: 'Ajman', nameLocal: 'عجمان'),
        MarketplaceCity(id: 'al_ain', name: 'Al Ain', nameLocal: 'العين'),
      ],
    ),
    MarketplaceCountry(
      code: 'SA',
      name: 'Saudi Arabia',
      nameLocal: 'السعودية',
      region: MarketplaceRegionId.middleEast,
      currency: sar,
      cities: [
        MarketplaceCity(id: 'riyadh', name: 'Riyadh', nameLocal: 'الرياض'),
        MarketplaceCity(id: 'jeddah', name: 'Jeddah', nameLocal: 'جدة'),
        MarketplaceCity(id: 'dammam', name: 'Dammam', nameLocal: 'الدمام'),
        MarketplaceCity(id: 'mecca', name: 'Mecca', nameLocal: 'مكة'),
        MarketplaceCity(id: 'medina', name: 'Medina', nameLocal: 'المدينة'),
      ],
    ),
    MarketplaceCountry(
      code: 'TR',
      name: 'Turkey',
      nameLocal: 'Türkiye',
      region: MarketplaceRegionId.middleEast,
      currency: tryCurrency,
      cities: [
        MarketplaceCity(id: 'istanbul', name: 'Istanbul', nameLocal: 'İstanbul'),
        MarketplaceCity(id: 'ankara', name: 'Ankara'),
        MarketplaceCity(id: 'izmir', name: 'Izmir', nameLocal: 'İzmir'),
        MarketplaceCity(id: 'gaziantep', name: 'Gaziantep'),
        MarketplaceCity(id: 'bursa', name: 'Bursa'),
        MarketplaceCity(id: 'antalya', name: 'Antalya'),
      ],
    ),
    MarketplaceCountry(
      code: 'KW',
      name: 'Kuwait',
      nameLocal: 'الكويت',
      region: MarketplaceRegionId.middleEast,
      currency: kwd,
      cities: [
        MarketplaceCity(id: 'kuwait_city', name: 'Kuwait City'),
        MarketplaceCity(id: 'hawalli', name: 'Hawalli'),
        MarketplaceCity(id: 'salmiya', name: 'Salmiya'),
      ],
    ),
    MarketplaceCountry(
      code: 'QA',
      name: 'Qatar',
      nameLocal: 'قطر',
      region: MarketplaceRegionId.middleEast,
      currency: qar,
      cities: [
        MarketplaceCity(id: 'doha', name: 'Doha', nameLocal: 'الدوحة'),
        MarketplaceCity(id: 'al_rayyan', name: 'Al Rayyan'),
      ],
    ),
    MarketplaceCountry(
      code: 'BH',
      name: 'Bahrain',
      nameLocal: 'البحرين',
      region: MarketplaceRegionId.middleEast,
      currency: bhd,
      cities: [
        MarketplaceCity(id: 'manama', name: 'Manama', nameLocal: 'المنامة'),
        MarketplaceCity(id: 'muharraq', name: 'Muharraq'),
      ],
    ),
    MarketplaceCountry(
      code: 'OM',
      name: 'Oman',
      nameLocal: 'عُمان',
      region: MarketplaceRegionId.middleEast,
      currency: omr,
      cities: [
        MarketplaceCity(id: 'muscat', name: 'Muscat', nameLocal: 'مسقط'),
        MarketplaceCity(id: 'salalah', name: 'Salalah'),
      ],
    ),
    MarketplaceCountry(
      code: 'JO',
      name: 'Jordan',
      nameLocal: 'الأردن',
      region: MarketplaceRegionId.middleEast,
      currency: jod,
      cities: [
        MarketplaceCity(id: 'amman', name: 'Amman', nameLocal: 'عمّان'),
        MarketplaceCity(id: 'irbid', name: 'Irbid'),
        MarketplaceCity(id: 'zarqa', name: 'Zarqa'),
      ],
    ),
    MarketplaceCountry(
      code: 'LB',
      name: 'Lebanon',
      nameLocal: 'لبنان',
      region: MarketplaceRegionId.middleEast,
      currency: lbp,
      cities: [
        MarketplaceCity(id: 'beirut', name: 'Beirut', nameLocal: 'بيروت'),
        MarketplaceCity(id: 'tripoli_lb', name: 'Tripoli'),
        MarketplaceCity(id: 'sidon', name: 'Sidon'),
      ],
    ),
    MarketplaceCountry(
      code: 'EG',
      name: 'Egypt',
      nameLocal: 'مصر',
      region: MarketplaceRegionId.middleEast,
      currency: egp,
      cities: [
        MarketplaceCity(id: 'cairo', name: 'Cairo', nameLocal: 'القاهرة'),
        MarketplaceCity(id: 'alexandria', name: 'Alexandria', nameLocal: 'الإسكندرية'),
        MarketplaceCity(id: 'giza', name: 'Giza', nameLocal: 'الجيزة'),
        MarketplaceCity(id: 'luxor', name: 'Luxor'),
      ],
    ),
  ];

  static List<MarketplaceCountry> get enabledCountries =>
      countries.where((c) => c.enabled).toList();

  static List<MarketplaceCountry> byRegion(MarketplaceRegionId region) =>
      enabledCountries.where((c) => c.region == region).toList();

  static MarketplaceCountry? countryByCode(String? code) {
    if (code == null) return null;
    final upper = code.toUpperCase();
    for (final c in countries) {
      if (c.code == upper) return c;
    }
    return null;
  }

  static MarketplaceCurrency? currencyByCode(String? code) {
    if (code == null) return null;
    final upper = code.toUpperCase();
    for (final c in currencies) {
      if (c.code == upper) return c;
    }
    return null;
  }

  static MarketplaceCity? cityInCountry(
    MarketplaceCountry country,
    String? cityId,
  ) {
    if (cityId == null) return null;
    for (final city in country.cities) {
      if (city.id == cityId) return city;
    }
    return null;
  }

  /// Default country suggestion — Iraq first for Kurdish/Arabic launch focus,
  /// with UK as European fallback when preferred.
  static MarketplaceCountry get defaultCountry =>
      countryByCode('IQ') ?? enabledCountries.first;

  static MarketplaceCountry get defaultEuropeanCountry =>
      countryByCode('GB') ?? byRegion(MarketplaceRegionId.europe).first;

  static MarketplaceCountry get defaultMiddleEastCountry =>
      countryByCode('IQ') ?? byRegion(MarketplaceRegionId.middleEast).first;
}
