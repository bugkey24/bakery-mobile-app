// lib/models/product_model.dart

class Product {
  final int? id;
  final String name;
  final String? description;
  final int price;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
  });

  // Konversi Map (dari SQLite) menjadi objek Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imagePath: map['image_path'],
    );
  }

  // Konversi objek Product menjadi Map (untuk insert/update ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
    };
  }
}
