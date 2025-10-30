// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:bakery_app/models/cart_item_model.dart';
import 'package:bakery_app/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  // === GETTER ===

  // Fall back all items in cart as a list
  List<CartItem> get items => _items.values.toList();

  // Mengembalikan jumlah item unik di keranjang (untuk ikon notifikasi)
  int get itemCount => _items.length;

  // Count total price of all items in cart
  int get totalPrice {
    int total = 0;
    // Loop all items, call 'subtotal' getter from CartItem
    _items.forEach((key, cartItem) {
      total += cartItem.subtotal;
    });
    return total;
  }

  // Count total quantity of all items in cart
  int get totalItemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  /// Add item to cart
  void addItem(Product product) {
    // Check if product already exists in cart
    if (_items.containsKey(product.id)) {
      // If it exists, increment the quantity
      _items.update(product.id!, (existingItem) {
        existingItem.increment();
        return existingItem;
      });
    } else {
      _items.putIfAbsent(product.id!, () => CartItem(product: product));
    }

    // Notify listeners to update UI
    notifyListeners();
  }

  /// Remove a single item from cart (decrement quantity)
  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      // If quantity > 1, just decrement quantity
      _items.update(productId, (existingItem) {
        existingItem.decrement();
        return existingItem;
      });
    } else {
      // If quantity is 1, remove from cart
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Remove all items (one row) from cart
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Clear all items from cart (after checkout)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
