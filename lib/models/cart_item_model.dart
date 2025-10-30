// lib/models/cart_item_model.dart
import 'package:bakery_app/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1, // Default quantity 1
  });

  // Function helper for increasing quantity
  void increment() {
    quantity++;
  }

  // Function helper for decreasing quantity
  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Function helper for calculating subtotal (price * quantity)
  int get subtotal => product.price * quantity;
}
