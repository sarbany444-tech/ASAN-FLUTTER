# ASAN Marketplace Regions

ASAN targets **Europe** and the **Middle East**.

## Catalog

Source of truth: `lib/core/constants/marketplace_regions.dart`

- Regions: Europe, Middle East
- Countries with major cities + local currency (EUR, GBP, IQD, AED, SAR, TRY, …)
- Currency auto-selects from the chosen country on create listing

Iraq includes Kurdish cities (Erbil, Sulaymaniyah, Dohuk, Kirkuk) with local names.

## App wiring

- **Add Post** → country / city / currency pickers
- **Search** → filter by region and country
- Home banner shows country coverage counts

## Play Console

Enable distribution for Europe + Middle East countries in Play Console
(Store presence → Countries/regions). The app catalog does not geo-block;
availability is controlled by Play.

## Adding a country

Append a `MarketplaceCountry` to `MarketplaceRegions.countries` with cities and
currency. No monetization or listing-engine changes required.
