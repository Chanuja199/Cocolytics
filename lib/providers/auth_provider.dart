import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';

enum AuthState { unknown, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.unknown;
  UserModel? _currentUser;
  String _errorMessage = '';

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _state == AuthState.authenticated;

  AuthProvider() {
    _init();
  }

  // Check if user is already logged in on app start
  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // User is logged in — load their profile
        _currentUser = await _authService.getCurrentUserProfile();
        _state = AuthState.authenticated;
      } else {
        _currentUser = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentUser = await _authService.login(email: email, password: password);

      // Cache user district locally for offline scan tagging
      LocalStorageService.saveString(
        AppConstants.userBox,
        'district',
        _currentUser!.district,
      );
      LocalStorageService.saveString(
        AppConstants.userBox,
        'userId',
        _currentUser!.id,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String city,
    required String district,
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        city: city,
        district: district,
      );

      // Cache locally
      LocalStorageService.saveString(
        AppConstants.userBox,
        'district',
        _currentUser!.district,
      );
      LocalStorageService.saveString(
        AppConstants.userBox,
        'userId',
        _currentUser!.id,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String district,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        phone: phone,
        address: address,
        city: city,
        district: district,
        profileImageUrl: profileImageUrl,
      );

      LocalStorageService.saveString(
        AppConstants.userBox,
        'district',
        _currentUser!.district,
      );
      LocalStorageService.saveString(
        AppConstants.userBox,
        'userId',
        _currentUser!.id,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.authenticated;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
