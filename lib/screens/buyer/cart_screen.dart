// lib/screens/buyer/cart_screen.dart
import 'package:bakery_app/providers/cart_provider.dart';
import 'package:bakery_app/screens/buyer/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch provider di level build
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: SafeArea(
        child: Column(
          children: [
            // --- DAFTAR ITEM KERANJANG ---
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cartData, child) {
                  if (cartData.items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemCount: cartData.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartData.items[index];
                      // --- KARTU ITEM KERANJANG BARU ---
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          elevation: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Ikon Produk
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[100],
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 30,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Nama & Harga Satuan
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${cartItem.product.price}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: kTextLightColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Kontrol Kuantitas & Hapus
                                Row(
                                  children: [
                                    // Tombol Kurang
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: kTextLightColor,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          cartData.removeSingleItem(
                                            cartItem.product.id!,
                                          );
                                        },
                                      ),
                                    ),
                                    // Tampilan Kuantitas
                                    SizedBox(
                                      width: 30, // Lebar tetap agar rapi
                                      child: Text(
                                        cartItem.quantity.toString(),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    // Tombol Tambah
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: kPrimaryDarkColor,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          cartData.addItem(cartItem.product);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 22,
                                        ),
                                        tooltip: 'Remove item',
                                        onPressed: () {
                                          // Tampilkan konfirmasi hapus (UX)
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Remove Item?'),
                                              content: Text(
                                                'Remove ${cartItem.product.name} from cart?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                ),
                                                TextButton(
                                                  child: const Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    cartData.removeItem(
                                                      cartItem.product.id!,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
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
                  );
                },
              ),
            ),

            // --- BAGIAN SUMMARY & CHECKOUT ---
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: kTextLightColor),
                      ),
                      Text(
                        'Rp ${cart.totalPrice}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp ${cart.totalPrice}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryDarkColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
