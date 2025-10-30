// lib/screens/admin/admin_order_detail_screen.dart
import 'package:bakery_app/models/order_model.dart';
import 'package:bakery_app/providers/auth_provider.dart';
import 'package:bakery_app/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final OrderHeader order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String _currentStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Pending',
    'Processed',
    'Shipped',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });
    final userId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).loggedInUser?.id;

    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).updateOrderStatus(
        widget.order.id,
        _currentStatus,
        currentUserId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error updating status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      appBar: AppBar(title: Text('Order #${widget.order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    DropdownButtonFormField<String>(
                      value: _currentStatus,
                      decoration: InputDecoration(
                        labelText: 'Order Status',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: kPrimaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        prefixIcon: const Icon(
                          Icons.sync_alt,
                          color: kPrimaryDarkColor,
                          size: 22,
                        ),
                      ),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentStatus = newValue;
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a status' : null,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: kTextDarkColor),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: kTextLightColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('Save Status'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Info Pembeli ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buyer Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: kPrimaryDarkColor,
                      ),
                      title: const Text(
                        'Username',
                        style: TextStyle(color: kTextLightColor, fontSize: 14),
                      ),
                      subtitle: Text(
                        widget.order.buyerUsername ?? 'N/A',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: kTextDarkColor),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: kPrimaryDarkColor,
                      ),
                      title: const Text(
                        'Delivery Location',
                        style: TextStyle(color: kTextLightColor, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Lat: ${widget.order.latitude.toStringAsFixed(6)}\nLong: ${widget.order.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kTextDarkColor,
                          height: 1.4,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Detail Items ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Items Ordered',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: ${currencyFormatter.format(widget.order.totalPrice)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.order.details.length,
                      itemBuilder: (context, index) {
                        final detail = widget.order.details[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: kTextLightColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail.productName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      '${detail.quantity} x ${currencyFormatter.format(detail.priceAtPurchase)}',
                                      style: TextStyle(
                                        color: kTextLightColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                currencyFormatter.format(detail.subtotal),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: kTextDarkColor,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 20, endIndent: 20),
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
