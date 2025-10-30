// lib/screens/buyer/order_history_screen.dart

import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/providers/order_provider.dart';
import 'package:bakery_app/screens/buyer/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(); // Helper function to fetch orders
    });
  }

  // Fungsi helper untuk fetch data (agar bisa dipakai di onRefresh)
  Future<void> _fetchOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.loggedInUser != null) {
      await Provider.of<OrderProvider>(
            context,
            listen: false,
          )
          .fetchUserOrders(authProvider.loggedInUser!.id!);
    }
  }

  // Fungsi helper untuk warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade700;
      case 'Processed':
        return Colors.blue.shade700;
      case 'Shipped':
        return Colors.purple.shade700;
      case 'Delivered':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Fungsi helper untuk ikon status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_top_rounded;
      case 'Processed':
        return Icons.inventory_2_outlined;
      case 'Shipped':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format mata uang (Indonesia)
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Tampilkan loading HANYA jika list kosong
          if (orderProvider.isLoading && orderProvider.userOrders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          // Tampilkan pesan kosong jika tidak loading dan list kosong
          if (orderProvider.userOrders.isEmpty && !orderProvider.isLoading) {
            return Center(
              child: Column(
                // Column agar bisa tambah icon
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You have no order history yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Gunakan RefreshIndicator untuk pull-to-refresh
          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: _fetchOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orderProvider.userOrders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.userOrders[index];
                // Format tanggal yang lebih baik
                final formattedDate = DateFormat(
                  'dd MMM yyyy, HH:mm',
                ).format(order.orderDate.toLocal());
                final statusColor = _getStatusColor(order.status);
                final statusIcon = _getStatusIcon(order.status);

                // --- KARTU RIWAYAT PESANAN BARU ---
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris 1: ID Pesanan & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                // Chip Status
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Baris 2: Tanggal
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: kTextLightColor),
                          ),
                          const SizedBox(height: 12),
                          // Baris 3: Ringkasan Item
                          Text(
                            '${order.details.length} item${order.details.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Divider(height: 24),
                          // Baris 4: Total Harga
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ), // Sedikit bold
                              Text(
                                currencyFormatter.format(
                                  order.totalPrice,
                                ), // Format harga
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryDarkColor,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
