// lib/screens/home_screen.dart
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/screens/admin/admin_dashboard_screen.dart';
import 'package:bakery_app/screens/buyer/buyer_dashboard_screen.dart';
import 'package:bakery_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // 2. Ambil data user yang sedang login
    final user = authProvider.loggedInUser;

    // 3. Cek Role dan kembalikan screen yang sesuai
    if (user == null) {
      // Ini adalah fallback (pengaman)
      // Seharusnya tidak pernah terjadi, tapi baik untuk ada
      return const LoginScreen();
    }

    if (user.role == 'admin') {
      // Jika rolenya 'admin', tampilkan Dashboard Admin
      return const AdminDashboardScreen();
    } else if (user.role == 'buyer') {
      // Jika rolenya 'buyer', tampilkan Dashboard Buyer
      return const BuyerDashboardScreen();
    } else {
      // Fallback jika role tidak dikenali
      return const LoginScreen();
    }
  }
}
