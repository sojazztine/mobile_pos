import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import 'user_model.dart';

class AuthModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isVendor => _currentUser?.isVendor ?? false;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('logged_in_user_id');

    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  // Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
    String role = 'user',
  }) async {
    // Check if email already exists
    final emailExists = await DatabaseHelper.instance.emailExists(email);
    if (emailExists) {
      return false;
    }

    // Create new user
    final user = User(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      address: address,
      role: role,
    );

    final createdUser = await DatabaseHelper.instance.createUser(user);
    if (createdUser != null) {
      _currentUser = createdUser;
      _isLoggedIn = true;

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('logged_in_user_id', createdUser.id!);

      notifyListeners();
      return true;
    }

    return false;
  }

  // Login user
  Future<bool> login(String email, String password) async {
    final user = await DatabaseHelper.instance.loginUser(email, password);

    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('logged_in_user_id', user.id!);

      notifyListeners();
      return true;
    }

    return false;
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;

    // Clear login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_id');

    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      fullName: fullName ?? _currentUser!.fullName,
      phone: phone ?? _currentUser!.phone,
      address: address ?? _currentUser!.address,
      profileImage: profileImage ?? _currentUser!.profileImage,
    );

    final result = await DatabaseHelper.instance.updateUser(updatedUser);
    if (result > 0) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }

    return false;
  }
}
