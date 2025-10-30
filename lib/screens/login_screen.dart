// lib/screens/login_screen.dart
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.login(
      _usernameController.text.trim(),
      _passwordControlle,
    );

    if (result == 'OK' && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Center konten secara vertikal & horizontal
          child: SingleChildScrollView(
            // Agar bisa scroll jika layar kecil
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- BAGIAN ATAS: LOGO/IKON ---
                const Icon(
                  Icons.bakery_dining_outlined,
                  size: 80,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 24),

                // --- TEKS SAMBUTAN ---
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kTextDarkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: kTextLightColor),
                ),
                const SizedBox(height: 40),

                // --- FORM LOGIN ---
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // Lupa Password Button
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        /* TODO: Implement forgot password */
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: kPrimaryDarkColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- TOMBOL LOGIN ---
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      // Style tombol diambil dari ThemeData
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('Login'),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // --- ATAU LOGIN DENGAN --- 
                // Row(
                //   children: <Widget>[
                //     Expanded(child: Divider()),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 8.0),
                //       child: Text("OR", style: TextStyle(color: kTextLightColor)),
                //     ),
                //     Expanded(child: Divider()),
                //   ],
                // ),
                // const SizedBox(height: 16),
                // Tombol Google/Facebook (jika diperlukan)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
