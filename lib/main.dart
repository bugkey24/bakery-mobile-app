// lib/main.dart

import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/screens/splash_screen.dart'; // Kita akan buat ini
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemChrome (Full Screen)
import 'package:google_fonts/google_fonts.dart'; // Untuk Font Bersih
import 'package:provider/provider.dart';

// Fungsi main() adalah gerbang utama
Future<void> main() async {
  // Pastikan semua binding Flutter siap sebelum menjalankan UI
  WidgetsFlutterBinding.ensureInitialized();

  // --- PENGATURAN FULL SCREEN (UI/UX) ---
  // Membuat status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparan
      statusBarIconBrightness: Brightness.dark, // Ikon (jam, baterai) jadi gelap
    ),
  );

  // Jalankan aplikasi dengan mendaftarkan Provider kita
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- TEMA MINIMALIS (UI/UX) ---
    final minimalistTheme = ThemeData(
      // Warna utama
      primarySwatch: Colors.brown, // Anda bisa ganti ini
      scaffoldBackgroundColor: Colors.white, // Latar belakang putih bersih

      // Tipografi Bersih (dari Google Fonts)
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

      // Tema untuk Text Field (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50], // Warna isian yang sangat terang
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, // Tidak ada border tebal
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.brown.shade400), // Border saat di-klik
        ),
      ),

      // Tema untuk Tombol (Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown, // Warna tombol
          foregroundColor: Colors.white, // Warna teks di tombol
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0, // Tidak ada bayangan, lebih minimalis
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
    // --- AKHIR DARI TEMA ---

    return MaterialApp(
      title: 'Bakery App',
      theme: minimalistTheme, // Terapkan tema kita
      debugShowCheckedModeBanner: false, // Hilangkan banner "DEBUG"
      
      // Kita mulai dari SplashScreen
      // SplashScreen akan memeriksa status login (UX yang baik)
      home: const SplashScreen(), 
    );
  }
}