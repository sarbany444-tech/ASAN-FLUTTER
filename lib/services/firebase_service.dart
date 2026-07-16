import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Returns true when Firebase started successfully.
  /// Returns false when config is still placeholders / unavailable (app can still UI-boot).
  static Future<bool> initialize() async {
    if (_initialized) return true;

    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.startsWith('YOUR_') || options.appId.startsWith('YOUR_')) {
      return false;
    }

    try {
      await Firebase.initializeApp(options: options);
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }
}
