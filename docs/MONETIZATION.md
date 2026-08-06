# ASAN Marketplace Monetization Architecture

Scalable, category-agnostic monetization for Europe & the Middle East.
**Launch rule: everything is free. Never restrict first-time UX.**

## Principles

1. **One engine for every category** — Buy & Sell, Cars, Real Estate, Jobs, Services, Companies, Shops, Restaurants, Hotels, Doctors, Teachers, Courses, Events, Freelancers.
2. **Firebase-remote control** — enable subscriptions, change prices/limits, and run campaigns without an app update.
3. **Modular revenue** — subscriptions, featured listings, verification, ads, in-app payments, and commissions are independent products.
4. **Launch = free** — track business interest and listing volume; show Business Plans as **Coming Soon**.

## Account model (every category)

| Capability | Personal (Free) | Business |
|---|---|---|
| Browse & message | Yes | Yes |
| Create listings | Yes (unlimited at launch) | Yes |
| Verification | Supported | Supported |
| Featured listings | Coming Soon / payable later | Credits + payable later |
| Premium services | Coming Soon | Plan or à la carte later |

## Firestore document

`config/monetization` (public read, admin write)

Key flags:

| Field | Launch | Meaning |
|---|---|---|
| `launchMode` | `true` | Free UX; Coming Soon for paid products |
| `subscriptionsEnabled` | `false` | Flip to `true` to sell Business plans |
| `paymentsEnforced` | `false` | When `false`, listing limits are not enforced |
| `freeCampaignActive` | `true` | Zero-friction campaign override |
| `featuredListingsEnabled` | `false` | Enable featured product |
| `verificationFeesEnabled` | `false` | Charge verification later |
| `advertisingEnabled` | `false` | Ads module |
| `commissionsEnabled` | `false` | Future take-rate |
| `inAppPaymentsEnabled` | `false` | Future IAP / checkout |
| `premiumServicesEnabled` | `false` | Boosts, highlights, etc. |
| `promotionsEnabled` | `false` | Promo campaigns |

Also nested: `plans`, `pricing`, `limits`, `categories`.

Seed file: [`firebase/seeds/monetization_config.json`](../firebase/seeds/monetization_config.json)

## Admin playbook (no app release)

1. Open Firestore → `config/monetization`.
2. To start charging Business plans:
   - set `launchMode: false`
   - set `freeCampaignActive: false`
   - set `subscriptionsEnabled: true`
   - set `paymentsEnforced: true`
3. Edit `pricing.*` and `limits.*` anytime.
4. Per-category: edit `categories.{id}` (`enabled`, `supportsBusiness`, …).
5. New category: add enum entry in app (next release) **or** temporarily add `categories.{newId}` for remote capability flags; register the enum when shipping UI.

## Client modules

| Path | Role |
|---|---|
| `lib/core/monetization/` | Categories, config models, entitlement engine |
| `lib/services/monetization_config_service.dart` | Live config stream |
| `lib/services/marketplace_tracking_service.dart` | Business interest + listing counts |
| `lib/services/revenue_ledger_service.dart` | Modular revenue events |
| `lib/services/monetization_service.dart` | Facade |
| `lib/providers/monetization_provider.dart` | App-wide state |
| `lib/screens/monetization/business_plans_screen.dart` | Coming Soon / plans UI |

## Tracking (launch)

- `business_interest` — users who tap Notify me
- `users.{uid}.interestedInBusiness` / `accountType`
- `analytics/platform_stats` — listing & business counters
- `listing_events` — create/remove telemetry
- `revenue_events` — deferred / interest / live charges

## Enabling paid products later

Flip the matching flag in `config/monetization`. The entitlement engine already branches on `isProductLive(...)`. Connect a payment provider (Play Billing / Stripe) behind `RevenueLedgerService.recordEvent` when ready — no rewrite of category logic.

## Goal

Grow trust and supply first. Monetize after density — same architecture from day one.
