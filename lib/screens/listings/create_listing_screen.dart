import 'package:flutter/material.dart';
import '../../core/constants/marketplace_regions.dart';
import '../../core/monetization/marketplace_category.dart';

/// Result produced by [CreateListingScreen] (local / pre-Firebase publish).
class CreateListingDraft {
  const CreateListingDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.countryCode,
    required this.cityId,
    required this.locationLabel,
    required this.currencyCode,
    required this.price,
    required this.priceLabel,
  });

  final String title;
  final String description;
  final MarketplaceCategory category;
  final String countryCode;
  final String cityId;
  final String locationLabel;
  final String currencyCode;
  final double price;
  final String priceLabel;
}

/// Create listing — Europe & Middle East location + local currency.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({
    super.key,
    this.initialCountryCode,
    this.accent = const Color(0xFFFFC83D),
    this.surface = const Color(0xFF0E1428),
    this.background = const Color(0xFF070B1A),
    this.onPrimary = const Color(0xFFF4F7FF),
    this.muted = const Color(0x8CF4F7FF),
  });

  final String? initialCountryCode;
  final Color accent;
  final Color surface;
  final Color background;
  final Color onPrimary;
  final Color muted;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  late MarketplaceRegionId _region;
  late MarketplaceCountry _country;
  late MarketplaceCity _city;
  MarketplaceCategory _category = MarketplaceCategory.buyAndSell;

  @override
  void initState() {
    super.initState();
    final initial = MarketplaceRegions.countryByCode(widget.initialCountryCode) ??
        MarketplaceRegions.defaultCountry;
    _country = initial;
    _region = initial.region;
    _city = initial.cities.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  List<MarketplaceCountry> get _countriesForRegion =>
      MarketplaceRegions.byRegion(_region);

  void _onRegionChanged(MarketplaceRegionId? region) {
    if (region == null) return;
    final countries = MarketplaceRegions.byRegion(region);
    setState(() {
      _region = region;
      _country = countries.first;
      _city = _country.cities.first;
    });
  }

  void _onCountryChanged(MarketplaceCountry? country) {
    if (country == null) return;
    setState(() {
      _country = country;
      _city = country.cities.first;
    });
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', ''));
    if (title.isEmpty) {
      _toast('Add a title');
      return;
    }
    if (price == null || price < 0) {
      _toast('Enter a valid price');
      return;
    }

    final draft = CreateListingDraft(
      title: title,
      description: _descCtrl.text.trim(),
      category: _category,
      countryCode: _country.code,
      cityId: _city.id,
      locationLabel: _country.locationLabel(_city),
      currencyCode: _country.currency.code,
      price: price,
      priceLabel: _country.currency.formatListing(price),
    );
    Navigator.of(context).pop(draft);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: widget.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = _country.currency;

    return Scaffold(
      backgroundColor: widget.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'New listing',
          style: TextStyle(color: widget.onPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: widget.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Europe & Middle East',
            style: TextStyle(
              color: widget.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your country — price currency updates automatically.',
            style: TextStyle(color: widget.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _FieldLabel('Region', color: widget.muted),
          const SizedBox(height: 6),
          _GlassDropdown<MarketplaceRegionId>(
            value: _region,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            items: MarketplaceRegionId.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.label),
                  ),
                )
                .toList(),
            onChanged: _onRegionChanged,
          ),
          const SizedBox(height: 14),
          _FieldLabel('Country', color: widget.muted),
          const SizedBox(height: 6),
          _GlassDropdown<MarketplaceCountry>(
            value: _country,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            items: _countriesForRegion
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text('${c.displayName} · ${c.currency.code}'),
                  ),
                )
                .toList(),
            onChanged: _onCountryChanged,
          ),
          const SizedBox(height: 14),
          _FieldLabel('City', color: widget.muted),
          const SizedBox(height: 6),
          _GlassDropdown<MarketplaceCity>(
            value: _city,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            items: _country.cities
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.displayName),
                  ),
                )
                .toList(),
            onChanged: (c) {
              if (c != null) setState(() => _city = c);
            },
          ),
          const SizedBox(height: 14),
          _FieldLabel('Category', color: widget.muted),
          const SizedBox(height: 6),
          _GlassDropdown<MarketplaceCategory>(
            value: _category,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            items: MarketplaceCategory.all
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.label),
                  ),
                )
                .toList(),
            onChanged: (c) {
              if (c != null) setState(() => _category = c);
            },
          ),
          const SizedBox(height: 14),
          _FieldLabel('Title', color: widget.muted),
          const SizedBox(height: 6),
          _GlassField(
            controller: _titleCtrl,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            hint: 'What are you offering?',
          ),
          const SizedBox(height: 14),
          _FieldLabel('Description', color: widget.muted),
          const SizedBox(height: 6),
          _GlassField(
            controller: _descCtrl,
            surface: widget.surface,
            onPrimary: widget.onPrimary,
            hint: 'Details, condition, availability…',
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          _FieldLabel('Price (${currency.code})', color: widget.muted),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.onPrimary.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  currency.symbol.trim(),
                  style: TextStyle(
                    color: widget.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassField(
                  controller: _priceCtrl,
                  surface: widget.surface,
                  onPrimary: widget.onPrimary,
                  hint: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Currency locked to ${_country.name}: ${currency.name} (${currency.code})',
            style: TextStyle(color: widget.muted, fontSize: 12),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: widget.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Publish listing',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.surface,
    required this.onPrimary,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final Color surface;
  final Color onPrimary;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: onPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: onPrimary.withValues(alpha: 0.35)),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: onPrimary.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: onPrimary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: onPrimary.withValues(alpha: 0.28)),
        ),
      ),
    );
  }
}

class _GlassDropdown<T> extends StatelessWidget {
  const _GlassDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.surface,
    required this.onPrimary,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color surface;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onPrimary.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: surface,
          style: TextStyle(color: onPrimary, fontSize: 14),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
