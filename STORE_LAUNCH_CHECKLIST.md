# ASAN — Store launch checklist

App ID: `com.sarbany444.asan`

## Done in the codebase

- [x] Unique Android/iOS app id (`com.sarbany444.asan`)
- [x] App display name **ASAN** (Android + iOS)
- [x] Web title / PWA manifest branded as ASAN
- [x] iOS privacy usage strings (camera, photos, location, mic)
- [x] Android release signing config (uses `android/key.properties` when present)
- [x] ProGuard rules for Flutter/Firebase release minify
- [x] Auth bypass off by default (enable with `--dart-define=BYPASS_AUTH=true`)
- [x] Safe Firebase boot (skips placeholders so UI still launches)
- [x] Codemagic iOS IPA workflow (`codemagic.yaml`)

## You must still do (manual / accounts)

### 1) Firebase (required for real backend)
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT
```
Add Android `google-services.json` and iOS `GoogleService-Info.plist`.

### 2) Android Play signing keystore
From `android/` folder (one time):

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" `
  -genkey -v -keystore asan-upload-keystore.jks -keyalg RSA -keysize 2048 `
  -validity 10000 -alias asan
```

Copy `key.properties.example` → `key.properties` and fill passwords.
**Back up the `.jks` file forever** — losing it blocks Play updates.

Build Play upload:

```powershell
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 3) Google Play Console
- Create app `ASAN`
- Upload AAB
- Complete Data safety, content rating, store listing, privacy policy URL

### 4) Apple / TestFlight (Codemagic)
- Register Bundle ID `com.sarbany444.asan`
- Create App Store Connect app
- Add API key secrets in Codemagic (`CODESIGNING_CODEMAGIC.md`)
- Build IPA → TestFlight → App Review

### 5) Privacy policy
Host a public privacy policy URL (required by both stores).

## Local test commands (Windows)

```powershell
# Web
flutter run -d chrome
flutter build web --release

# Android (device/emulator)
flutter run -d android
flutter build apk --release
flutter build appbundle --release

# iOS: use Codemagic (cannot build IPA on Windows)
```

## Honest status

| Platform | Runnable now | Store-submittable now |
|----------|--------------|------------------------|
| Web      | Yes (UI)     | Host + Firebase needed |
| Android  | Yes (UI)     | After keystore + AAB + Play listing |
| iPhone   | Via Codemagic/TestFlight | After signing + App Review |

The marketplace UI runs on all three platforms. Full publish still needs Firebase + store accounts + (for Android) your keystore.
