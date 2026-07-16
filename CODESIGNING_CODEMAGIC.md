# Codemagic setup for ASAN Flutter (iOS IPA)
#
# This file is a human checklist. The build definition is in `codemagic.yaml`.

## Prerequisites

1. Apple Developer Program membership (paid) — required for TestFlight / proper device installs.
2. GitHub repo: https://github.com/sarbany444-tech/ASAN-FLUTTER
3. Codemagic account: https://codemagic.io (sign in with GitHub).

## Important: Bundle ID

Your iOS / Android app ID is:

```
com.sarbany444.asan
```

Register this exact Bundle ID in Apple Developer → Identifiers, and in App Store Connect.

Do **not** use 3uTools resign after Codemagic — install via TestFlight instead.

## Step-by-step setup

### 1) Push `codemagic.yaml` to GitHub

From the project folder (after you commit locally):

```powershell
cd "C:\Users\sarba\OneDrive\Desktop\flutter projects\flutter_application_1"
git add codemagic.yaml CODESIGNING_CODEMAGIC.md
git commit -m "Add Codemagic iOS IPA workflow"
git push origin main
```

### 2) Add the app in Codemagic

1. Open https://codemagic.io
2. **Add application** → select **ASAN-FLUTTER**
3. Project type: **Flutter**
4. Select workflow: **ios-release** (from `codemagic.yaml`)

### 3) Create App Store Connect API key

1. https://appstoreconnect.apple.com → **Users and Access** → **Integrations** → **App Store Connect API**
2. Generate a key with **App Manager** (or Admin) access
3. Download `AuthKey_XXXXXXXX.p8` (once only)
4. Note:
   - Issuer ID
   - Key ID
   - Private key file contents

### 4) Create App Store Connect app

1. App Store Connect → **My Apps** → **+**
2. Platform: iOS
3. Name: ASAN
4. Bundle ID: `com.sarbany444.asan`
5. Copy the numeric **Apple ID** of the app (App Information) into Codemagic later if publishing to TestFlight

### 5) Codemagic code signing

In Codemagic → your app → **Code signing identities** (or Environment variables):

Create environment group: `app_store_credentials`

Add secrets:

| Variable | Value |
|----------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Full contents of the `.p8` file |
| `CERTIFICATE_PRIVATE_KEY` | New RSA private key (see below) |

Generate `CERTIFICATE_PRIVATE_KEY` on Windows (OpenSSL or Git Bash):

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt
```

Paste the entire PEM block (including `BEGIN` / `END`) as the secret value.

Codemagic will create/fetch certificates + provisioning profiles automatically when the build runs `app-store-connect fetch-signing-files`.

### 6) First build (IPA only)

1. Codemagic → **Start new build**
2. Workflow: `ios-release`
3. Branch: `main`
4. When finished, download the `.ipa` from **Artifacts**

That IPA is properly signed (App Store distribution). Prefer TestFlight over sideloading tools.

### 7) Enable TestFlight publishing (optional)

In `codemagic.yaml`, set `APP_STORE_APP_ID` and uncomment the `app_store_connect` publishing block.

Then:

1. Rebuild
2. Open **TestFlight** on your iPhone
3. Accept the invite / install internal build
4. Open ASAN from TestFlight (this avoids the 3uTools crash-on-open issue)

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Signing / profile errors | Confirm Bundle ID matches App Store Connect + API key permissions |
| `pod install` fails | Check Codemagic logs; often fixed by CocoaPods cache clear / rebuild |
| Firebase crashes on launch | Add real `GoogleService-Info.plist` under `ios/Runner/` and commit it (or inject via Codemagic secure files) |
| Build works but TestFlight missing | Uncomment publishing + set App Store Apple ID |
| Instant crash after install | Do **not** resign with 3uTools; use TestFlight install |

## Local reminder (Windows)

You still **cannot** run `flutter build ipa` on Windows. Codemagic (cloud Mac) is the correct path.
