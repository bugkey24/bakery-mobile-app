// lib/screens/buyer/order_success_screen.dart
import 'package:bakery_app/screens/buyer/buyer_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:bakery_app/main.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

// Tambahkan TickerProviderStateMixin untuk animasi
class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  // Deklarasi Controller & Animasi
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Buat Animasi Scale (dari 0 ke 1)
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bungkus Ikon dengan ScaleTransition
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(
                    Icons.check_circle,
                    color: kPrimaryDarkColor,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 32),

                // Teks Utama
                Text(
                  'Order Confirmed!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kTextDarkColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Teks Deskripsi
                Text(
                  'Thank you for your purchase. The admin will process your order shortly.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: kTextLightColor),
                ),
                const SizedBox(height: 48),

                // Tombol Kembali ke Toko
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const BuyerDashboardScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  // Style tombol diambil dari ThemeData
                  child: const Text('Back to Store'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
