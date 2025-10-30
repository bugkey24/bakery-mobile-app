// lib/screens/splash_screen.dart
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/screens/home_screen.dart';
import 'package:bakery_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Pesan loading
  final String _loadingMessage = "Loading your bakery...";

  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback untuk memastikan frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mulai delay setelah frame pertama
      Future.delayed(const Duration(seconds: 5), () {
        // Panggil check auth setelah delay, pastikan widget masih ada
        if (mounted) {
          _checkAuthStatus();
        }
      });
    });
  }

  Future<void> _checkAuthStatus() async {
    // Logika cek auth tetap sama
    try {
      // Gunakan context yang aman (jika masih diperlukan setelah delay)
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      // Gunakan context lagi setelah await, cek mounted lagi
      if (!mounted) return;

      if (authProvider.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("Error during splash screen auth check: $e");
      if (mounted) {
        // Default ke Login screen jika ada error
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Splash Screen (Sama seperti sebelumnya)
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bakery_dining, size: 100, color: Colors.black),
            const SizedBox(height: 24),
            Text(
              'Bakery App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              _loadingMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
