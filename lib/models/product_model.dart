// lib/models/product_model.dart
// This model represents a product in the bakery app
class Product {
  final int? id;
  final String name;
  final String? description;
  final int price;

// Constructor to create a new product
  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
  });

// Conversion Map to object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }

// Conversion object to Map (for inserting into SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}
