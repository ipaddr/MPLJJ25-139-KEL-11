import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  /// Login user dan ambil data dari Firestore
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _currentUser = await _firestoreService.getUserById(user.uid);
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Set current user secara manual (misalnya setelah register)
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Cek login saat startup
  Future<void> checkLoginStatus() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _firestoreService.getUserById(firebaseUser.uid);
    }
    notifyListeners();
  }
}
