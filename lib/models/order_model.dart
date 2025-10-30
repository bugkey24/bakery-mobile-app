// lib/models/order_model.dart
// This model represents an order with its details
class OrderDetail {
  final String productName;
  final int quantity;
  final int priceAtPurchase;

  OrderDetail({
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  // Factory for creating from map (query result)
  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      productName: map['product_name'],
      quantity: map['quantity'],
      priceAtPurchase: map['price_at_purchase'],
    );
  }

  // Helper untuk subtotal
  int get subtotal => priceAtPurchase * quantity;
}

// This model represents the main data (header) of an order
class OrderHeader {
  final int id;
  final String? buyerUsername;
  final int totalPrice;
  final String status;
  final DateTime orderDate;
  final double latitude;
  final double longitude;
  final List<OrderDetail> details;

  OrderHeader({
    required this.id,
    this.buyerUsername,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.latitude,
    required this.longitude,
    required this.details,
  });

  // Factory for creating from map (query result)
  factory OrderHeader.fromMap(
    Map<String, dynamic> map,
    List<OrderDetail> details,
  ) {
    return OrderHeader(
      id: map['id'],
      buyerUsername: map['buyer_username'],
      totalPrice: map['total_price'],
      status: map['status'],
      orderDate: DateTime.parse(
        map['order_date'],
      ),
      latitude: map['latitude'],
      longitude: map['longitude'],
      details: details,
    );
  }
}
