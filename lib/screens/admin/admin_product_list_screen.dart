// lib/screens/admin/admin_product_list_screen.dart
// Contains the Product List (CRUD)
import 'package:bakery_app/models/product_model.dart';
import 'package:bakery_app/providers/product_provider.dart';
import 'package:bakery_app/screens/admin/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bakery_app/main.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});
  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch product data when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  // Navigate to the form (for add/edit)
  void _navigateToProductForm(Product? product) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProductFormScreen(product: product),
          ),
        )
        .then((_) {
          // Refresh list after returning from form (if changes were made)
          Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        });
  }

  // --- REVISED: Logic for deleting a product ---
  Future<void> _deleteProduct(int id) async {
    final bool? confirmed = await showDialog<bool>(
      // 1. Added 'context' argument
      context: context,
      // 2. Added 'builder' argument
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to delete this product?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    // 3. Added 'mounted' check before using context/provider
    if (confirmed == true && mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      await provider.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          if (productProvider.products.isEmpty && !productProvider.isLoading) {
            return const Center(
              child: Text(
                'No products found. Tap (+) to add one.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () => Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProducts(),
            child: ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Price: Rp ${product.price}\n${product.description ?? ""}',
                    ),
                    isThreeLine:
                        product.description != null &&
                        product.description!.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: kPrimaryDarkColor,
                          ),
                          tooltip: 'Edit',
                          onPressed: () => _navigateToProductForm(product),
                        ),
                        // Pass only the ID to _deleteProduct
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Delete',
                          onPressed: () => _deleteProduct(product.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(null),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }
}
