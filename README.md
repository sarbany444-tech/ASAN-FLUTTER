# Naseem — Islamic Short-Video Social Platform (v2.0)

**Naseem** (نسيم) is a production-ready Flutter application with TikTok-style UX, dedicated exclusively to beneficial Islamic content. Version 2 adds full social features, personalized feeds, creator tools, messaging, live streaming architecture, and monetization preparation — all protected by AI moderation.

## What's New in v2.0

### TikTok-Style Video Feed
- Full-screen vertical swipe with **real video playback** (auto play/pause)
- **For You**, **Following**, and **Trending** tabs
- Infinite scroll with cursor pagination
- Video preloading for smooth performance
- Personalized recommendation algorithm (watch history, category prefs, engagement)

### Video Creation
- Camera recording + gallery upload
- Video editor (trim, text overlays, filters)
- Hashtags, captions, privacy settings (public/followers/private)
- Local + cloud draft saving
- AI moderation before publish

### Social Network
- Likes, comments, reply threads
- Follow/unfollow with notifications
- Save videos, watch history, share
- User mentions (@username)
- In-app notifications

### Discovery
- Search videos, users, hashtags
- Trending Islamic content
- Recommended verified creators
- Category browsing

### Creator Tools
- Creator analytics dashboard (views, likes, followers)
- Verified Islamic creator badge
- Top performing videos

### Messaging & Live
- Direct messages + chat
- Live streaming architecture (WebRTC/RTMP ready)
- Live comments and reactions with moderation

### Monetization (ASAN Marketplace)
- Category-agnostic engine for all 14 marketplace categories
- Personal (Free) + Business accounts, verification, featured, premium
- Launch mode: everything free; Business Plans shown as Coming Soon
- Admin remote control via Firestore `config/monetization` (no app update)
- See [docs/MONETIZATION.md](docs/MONETIZATION.md)

---

## Features

### Core Platform
- Vertical short-video feed with likes, comments, shares, and reports
- Category-based explore (Quran, Hadith, Lectures, Nasheed, etc.)
- User profiles with verified scholar badges
- Search across approved content
- Multi-language support: **English**, **Arabic**, **Kurdish**

### Islamic Tools
- Prayer times (GPS-based, Muslim World League calculation)
- Qibla compass direction
- Hijri Islamic calendar
- Daily Quran verse, Hadith, and reminders

### Content Moderation
- AI-powered video analysis pipeline (Cloud Functions)
- Speech-to-text transcription
- Automatic keyword filtering
- Community reporting system
- Human admin/moderator review dashboard
- User strike system (3 strikes = suspension, 5 = ban)

### User Roles
| Role | Capabilities |
|------|-------------|
| User | Upload, view, report content |
| Verified Scholar | Verified badge, priority moderation |
| Moderator | Review queue, handle reports |
| Administrator | Full dashboard, user management, bans |

## Tech Stack

- **Frontend:** Flutter 3.12+, Material 3, Provider, GoRouter
- **Backend:** Firebase Auth, Firestore, Storage, Cloud Functions
- **AI Layer:** Google Cloud Vision + Speech-to-Text (Cloud Functions)
- **Islamic APIs:** Adhan (prayer times), Hijri calendar

## Project Structure

```
lib/
├── core/           # Theme, constants, routing
├── l10n/           # Localization (en, ar, ku)
├── models/         # Data models
├── providers/      # State management
├── screens/        # All UI screens
├── services/       # Firebase & business logic
└── widgets/        # Reusable components

firebase/
├── functions/      # Cloud Functions (moderation pipeline)
├── firestore.rules
├── storage.rules
└── firestore.indexes.json
```

## Getting Started

### Prerequisites
- Flutter SDK 3.12+
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Node.js 20+ (for Cloud Functions)

### 1. Clone and Install Dependencies

```bash
cd flutter_application_1
flutter pub get
```

### 2. Firebase Setup

```bash
# Login to Firebase
firebase login

# Create a new Firebase project (or use existing)
firebase projects:create naseem-app

# Configure Flutter app with Firebase
flutterfire configure --project=naseem-app
```

This generates `lib/firebase_options.dart` with your project credentials.

### 3. Enable Firebase Services

In the [Firebase Console](https://console.firebase.google.com):

1. **Authentication** → Enable Email/Password sign-in
2. **Firestore Database** → Create database (production mode)
3. **Storage** → Enable Cloud Storage
4. **Functions** → Upgrade to Blaze plan (required for Cloud Functions)

### 4. Deploy Firebase Rules and Functions

```bash
cd firebase
npm install --prefix functions
firebase deploy --only firestore:rules,storage:rules,firestore:indexes
firebase deploy --only functions
```

### 5. Seed Daily Content (Optional)

Add documents to Firestore collection `daily_content`:

```json
// Document ID: quran_verse
{
  "type": "quran",
  "arabicText": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
  "translation": "Indeed, with hardship comes ease.",
  "reference": "Quran 94:6",
  "source": "Surah Ash-Sharh"
}

// Document ID: hadith
{
  "type": "hadith",
  "arabicText": "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
  "translation": "Actions are judged by intentions.",
  "reference": "Sahih al-Bukhari & Muslim"
}
```

### 6. Create Admin User

After registering a user in the app, update their role in Firestore:

```
users/{userId} → role: "administrator"
```

For moderator: `role: "moderator"`
For verified scholar: `role: "verified_scholar"`, `isVerified: true`

### 7. Run the App

```bash
flutter run
```

## Deployment

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

Upload the AAB to Google Play Console.

### iOS

```bash
flutter build ios --release
```

Open Xcode, configure signing, and upload to App Store Connect.

### Web

```bash
flutter build web --release
firebase hosting:channel:deploy preview
```

## Content Policy

All uploads pass through this pipeline before publishing:

1. **Client pre-check** — Keyword and category validation
2. **Upload to Firebase Storage**
3. **Cloud Function trigger** — Frame analysis, audio transcription, keyword scan
4. **Auto-decision** — Approve / Reject / Send to human review
5. **Community reports** — 3+ reports auto-remove content

### Allowed Categories
Quran recitation, memorization, Tafsir, Hadith, lectures, reminders, nasheed (vocals only), Arabic learning, Islamic history, children education, charity, general Islamic education.

### Prohibited Content
Music videos, entertainment, dancing, inappropriate behavior, violence, gambling, alcohol/drugs, dating, adult content, hate speech, political propaganda.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Flutter App │────▶│   Firebase   │────▶│ Cloud Functions │
│  (Provider)  │     │ Auth/Store/DB│     │ AI Moderation   │
└─────────────┘     └──────────────┘     └─────────────────┘
       │                    │                      │
       │                    ▼                      ▼
       │             ┌──────────────┐     ┌─────────────────┐
       └────────────▶│  Firestore   │     │ Vision + Speech │
                     │  Real-time   │     │ API Analysis    │
                     └──────────────┘     └─────────────────┘
```

## Environment Variables (Cloud Functions)

Set in Firebase Functions config:

```bash
firebase functions:config:set google.cloud_project="naseem-app"
```

Enable APIs in Google Cloud Console:
- Cloud Vision API
- Cloud Speech-to-Text API

## License

Private — All rights reserved.

---

Built with Flutter and Firebase for the Muslim community.
