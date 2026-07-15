import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/dev_accounts.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    if (AppConstants.bypassAuthForDevelopment) {
      _user = DevAccounts.guestCreator;
    }
  }

  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role.isAdmin ?? false;
  bool get isTeacher => _user?.role.isTeacher ?? false;
  bool get isStudent => _user?.role.isStudent ?? false;
  bool get isModerator => _user?.role.isModerator ?? false;

  Future<void> init() async {
    if (AppConstants.bypassAuthForDevelopment) {
      _user = DevAccounts.guestCreator;
      notifyListeners();
    }

    try {
      final firebaseUser = await _authService.getCurrentUser();
      if (firebaseUser != null) {
        _user = firebaseUser;
      }
    } catch (_) {
      // Firebase may be unavailable locally — keep dev guest when enabled.
    }

    _user ??=
        AppConstants.bypassAuthForDevelopment ? DevAccounts.guestCreator : null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String displayName, {
    UserRole role = UserRole.student,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user =
        AppConstants.bypassAuthForDevelopment ? DevAccounts.guestCreator : null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.getCurrentUser();
    } catch (_) {
      _user = null;
    }
    _user ??=
        AppConstants.bypassAuthForDevelopment ? DevAccounts.guestCreator : null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? preferredLanguage,
  }) async {
    if (_user == null) return;
    await _authService.updateProfile(
      uid: _user!.uid,
      displayName: displayName,
      bio: bio,
      preferredLanguage: preferredLanguage,
    );
    await refreshUser();
  }

  /// Wraps existing Firebase Auth password-reset — no query/routing changes.
  Future<bool> sendPasswordReset(String email) async {
    _error = null;
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
