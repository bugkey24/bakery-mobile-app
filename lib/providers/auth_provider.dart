// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:bakery_app/data/database_service.dart';
import 'package:bakery_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _loggedInUser;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get loggedInUser => _loggedInUser;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      final prefs = await _getPrefs();
      int? userId = prefs.getInt('loggedInUserId');
      if (userId != null) {
        final user = await _dbService.getUserById(userId);
        if (user != null) {
          _loggedInUser = user;
          _isLoggedIn = true;
        } else {
          await prefs.remove('loggedInUserId');
        }
      }
    } catch (e) {
      print("Error in checkLoginStatus: $e");
      _isLoggedIn = false;
      _loggedInUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _dbService.getUserByUsernameAndPassword(
        username,
        password,
      );
      if (user != null) {
        _loggedInUser = user;
        _isLoggedIn = true;
        final prefs = await _getPrefs();
        await prefs.setInt('loggedInUserId', user.id!);
        notifyListeners();
        return 'OK';
      } else {
        return 'Invalid username or password.';
      }
    } catch (e) {
      print("Error during login: $e"); // Cetak error untuk debug
      return 'An error occurred during login. Please check database connection.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _loggedInUser = null;
    _isLoggedIn = false;
    final prefs = await _getPrefs();
    await prefs.remove('loggedInUserId');
    notifyListeners();
  }
}
