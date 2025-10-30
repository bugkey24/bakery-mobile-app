// lib/screens/buyer/order_detail_screen.dart
import 'package:bakery_app/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderHeader order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final formattedDate = order.orderDate
        .toLocal()
        .toString()
        .split('.')[0]
        .replaceFirst(' ', '\n');

    return Scaffold(
      appBar: AppBar(title: Text('Order Receipt #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info Pesanan ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Order Date'),
                      subtitle: Text(formattedDate),
                    ),
                    ListTile(
                      title: const Text('Status'),
                      subtitle: Text(
                        order.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                      ),
                    ),
                    ListTile(
                      title: const Text('Total Price'),
                      subtitle: Text(
                        'Rp ${order.totalPrice}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Rincian Item ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items Ordered',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    // Tampilkan semua item
                    ...order.details.map((detail) {
                      return ListTile(
                        title: Text(detail.productName),
                        subtitle: Text(
                          '${detail.quantity} x Rp ${detail.priceAtPurchase}',
                        ),
                        trailing: Text(
                          'Rp ${detail.subtotal}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Info Lokasi ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Coordinates'),
                      subtitle: Text(
                        'Lat: ${order.latitude}\nLong: ${order.longitude}',
                      ),
                      isThreeLine: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
