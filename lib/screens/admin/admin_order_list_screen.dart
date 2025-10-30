// lib/screens/admin/admin_order_list_screen.dart
import 'package:bakery_app/providers/order_provider.dart';
import 'package:bakery_app/screens/admin/admin_order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllOrders();
    });
  }

  // Fungsi helper untuk fetch data
  Future<void> _fetchAllOrders() async {
    await Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
  }

  // Fungsi helper warna & ikon
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
    // Format mata uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.allOrders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          if (orderProvider.allOrders.isEmpty && !orderProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders received yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Gunakan RefreshIndicator
          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: _fetchAllOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orderProvider.allOrders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.allOrders[index];
                final formattedDate = DateFormat(
                  'dd MMM yyyy, HH:mm',
                ).format(order.orderDate.toLocal());
                final statusColor = _getStatusColor(order.status);
                final statusIcon = _getStatusIcon(order.status);

                // --- KARTU RIWAYAT PESANAN ADMIN ---
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // Navigasi ke halaman detail Admin
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminOrderDetailScreen(order: order),
                            ),
                          )
                          .then((_) {
                            _fetchAllOrders();
                          });
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
                          // Baris 2: Username Pembeli
                          Text(
                            'Buyer: ${order.buyerUsername ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: kTextDarkColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          // Baris 3: Tanggal
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: kTextLightColor),
                          ),
                          const Divider(height: 24),
                          // Baris 4: Total Harga & Panah
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormatter.format(order.totalPrice),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryDarkColor,
                                    ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: kTextLightColor,
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
