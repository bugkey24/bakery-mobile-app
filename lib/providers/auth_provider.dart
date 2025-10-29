// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:bakery_app/data/database_service.dart';
import 'package:bakery_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Menggunakan ChangeNotifier
// Ini adalah inti dari Provider.
// Ini akan 'memberi tahu' UI untuk update saat ada perubahan data.
class AuthProvider with ChangeNotifier {
  // --- State (Data Internal) ---

  // Service untuk berinteraksi dengan database
  final DatabaseService _dbService = DatabaseService.instance;

  // State untuk melacak status
  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _loggedInUser;

  // --- Getters (Cara UI Membaca State) ---
  // UI hanya bisa 'membaca' data melalui ini, tidak bisa mengubah langsung.
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get loggedInUser => _loggedInUser;

  // --- Private Helper ---

  // Helper untuk mengelola status loading dan memberi tahu UI
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // <--- Ini yang memicu UI untuk rebuild
  }

  // Helper untuk inisialisasi SharedPreferences
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // --- Public Methods (Logika Bisnis) ---

  /// Memeriksa apakah ada sesi login yang tersimpan saat aplikasi dimulai.
  Future<void> checkLoginStatus() async {
    _setLoading(true);

    final prefs = await _getPrefs();
    int? userId = prefs.getInt('loggedInUserId');

    if (userId != null) {
      // Jika ada ID tersimpan, coba ambil data user dari DB
      final user = await _dbService.getUserById(userId);
      if (user != null) {
        _loggedInUser = user;
        _isLoggedIn = true;
      } else {
        // ID tersimpan tapi user tidak ada (mungkin terhapus), hapus session
        await prefs.remove('loggedInUserId');
      }
    }

    _setLoading(false); // Selesai loading, notify UI
  }

  /// Mencoba untuk login dengan username dan password.
  /// Mengembalikan String 'OK' jika berhasil, atau pesan error jika gagal.
  Future<String> login(String username, String password) async {
    _setLoading(true);

    try {
      final user = await _dbService.getUserByUsernameAndPassword(
        username,
        password,
      );

      if (user != null) {
        // --- SUKSES LOGIN ---
        _loggedInUser = user;
        _isLoggedIn = true;

        // Simpan sesi ke SharedPreferences
        final prefs = await _getPrefs();
        await prefs.setInt('loggedInUserId', user.id!);

        notifyListeners(); // Beri tahu UI bahwa user sudah login
        return 'OK'; // Kembalikan status sukses
      } else {
        // --- GAGAL LOGIN ---
        return 'Invalid username or password.'; // Kembalikan pesan error
      }
    } catch (e) {
      // --- ERROR ---
      return 'An error occurred: $e'; // Kembalikan pesan error teknis
    } finally {
      // Pastikan loading dihentikan apapun hasilnya
      _setLoading(false);
    }
  }

  /// Mengeluarkan pengguna dari aplikasi.
  Future<void> logout() async {
    _loggedInUser = null;
    _isLoggedIn = false;

    // Hapus sesi dari SharedPreferences
    final prefs = await _getPrefs();
    await prefs.remove('loggedInUserId');

    notifyListeners(); // Beri tahu UI bahwa user sudah logout
  }
}
