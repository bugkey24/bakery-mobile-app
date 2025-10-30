// lib/screens/buyer/checkout_screen.dart
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/providers/cart_provider.dart';
import 'package:bakery_app/data/database_service.dart';
import 'package:bakery_app/screens/buyer/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoadingLocation = false;
  Position? _position;
  String? _locationError;
  bool _isLoadingOrder = false;

  // --- Fungsi untuk mendapatkan lokasi GPS ---
  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Tambahkan try-catch di sekitar logika Geolocator
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location services are disabled. Please enable it.';
        });
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = 'Location permissions are denied.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationError =
              'Location permissions are permanently denied, we cannot request permissions.';
        });
        return;
      }
      // Dapatkan Posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _isLoadingLocation = false;
        _position = position;
      });
    } catch (e) {
      // Tangani error umum
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Failed to get location: $e';
      });
      print("Error determining position: $e");
    } finally {
      // Pastikan loading berhenti jika ada error tak terduga
      if (_isLoadingLocation && mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // --- Fungsi untuk mengonfirmasi pesanan ---
  Future<void> _confirmOrder() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get your location first.')),
      );
      return;
    }
    setState(() {
      _isLoadingOrder = true;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cart = Provider.of<CartProvider>(context, listen: false);
      final currentUser = auth.loggedInUser;
      final cartItems = cart.items;
      final totalPrice = cart.totalPrice;

      if (currentUser != null) {
        await DatabaseService.instance.createTransaction(
          currentUser,
          cartItems,
          totalPrice,
          _position!,
        );
        cart.clearCart();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          );
        }
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      print("Error confirming order: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrder = false;
        });
      }
    }
  }

  // --- Widget untuk menampilkan status lokasi ---
  Widget _buildLocationStatus() {
    Widget content;
    Color color = kTextLightColor;

    if (_isLoadingLocation) {
      content = const Text(
        'Getting your location...',
        textAlign: TextAlign.center,
      );
      color = kPrimaryDarkColor;
    } else if (_locationError != null) {
      content = Text(_locationError!, textAlign: TextAlign.center);
      color = Colors.redAccent;
    } else if (_position != null) {
      content = Text(
        'Location Acquired:\nLat: ${_position!.latitude.toStringAsFixed(6)}\nLong: ${_position!.longitude.toStringAsFixed(6)}',
        textAlign: TextAlign.center,
      );
      color = kPrimaryDarkColor;
    } else {
      content = const Text(
        'Please get your location for delivery.',
        textAlign: TextAlign.center,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 15, color: color),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Order Summary ---
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Rp ${cart.totalPrice}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Delivery Location ---
              Text(
                'Delivery Location',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildLocationStatus(),
              ElevatedButton.icon(
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kPrimaryDarkColor,
                        ),
                      )
                    : const Icon(
                        Icons.my_location,
                        size: 20,
                        color: kPrimaryDarkColor,
                      ),
                label: const Text('Get My Location'),
                onPressed: _isLoadingLocation ? null : _determinePosition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor.withOpacity(0.15),
                  foregroundColor: kPrimaryDarkColor,
                  elevation: 0,
                  side: const BorderSide(color: kPrimaryColor),
                ),
              ),
              const SizedBox(height: 48),

              // --- Confirm Order Button ---
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: _isLoadingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Confirm Order'),
                onPressed: (_position == null || _isLoadingOrder)
                    ? null
                    : _confirmOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
