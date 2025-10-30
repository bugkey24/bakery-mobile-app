// lib/screens/admin/admin_dashboard_screen.dart
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/screens/admin/admin_product_list_screen.dart';
import 'package:bakery_app/screens/admin/admin_order_list_screen.dart';
import 'package:bakery_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Menu 1: Manage Products ---
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.bakery_dining_outlined,
                size: 40,
                color: Colors.brown,
              ),
              title: const Text('Manage Products'),
              subtitle: const Text('Add, edit, or delete products'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminProductListScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          // --- Menu 2: Manage Orders ---
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: Colors.brown,
              ),
              title: const Text('Manage Orders'),
              subtitle: const Text('View orders and update status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminOrderListScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
