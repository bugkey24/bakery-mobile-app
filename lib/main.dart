// lib/main.dart
// Hapus import DatabaseService jika ada
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/providers/product_provider.dart';
import 'package:bakery_app/providers/cart_provider.dart';
import 'package:bakery_app/providers/order_provider.dart';
import 'package:bakery_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Palet Warna 
const kPrimaryColor = Color(0xFFF7C548);
const kPrimaryDarkColor = Color(0xFFE6A919);
const kBackgroundColor = Color(0xFFFCFCFC);
const kTextDarkColor = Color(0xFF222222);
const kTextLightColor = Color(0xFF7A7A7A);

Future<void> main() async {
  // Hanya ensureInitialized dan SystemChrome
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Tanpa await database
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema baru tetap digunakan
    final newTheme = ThemeData(
      primaryColor: kPrimaryColor,
      scaffoldBackgroundColor: kBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        primary: kPrimaryColor,
        secondary: kPrimaryDarkColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      ).apply(bodyColor: kTextDarkColor, displayColor: kTextDarkColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          disabledBackgroundColor:
              Colors.grey.shade300, // Warna background saat disabled
          disabledForegroundColor:
              Colors.grey.shade500, // Warna teks/ikon saat disabled
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
        ),
        labelStyle: const TextStyle(color: kTextLightColor),
      ),
      cardTheme: CardThemeData(
        elevation: 1.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        foregroundColor: kTextDarkColor,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: kTextDarkColor,
        ),
      ),
    );

    return MaterialApp(
      title: 'Bakery App',
      theme: newTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
