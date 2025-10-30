// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:bakery_app/data/database_service.dart';
import 'package:bakery_app/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  List<OrderHeader> _userOrders = [];
  List<OrderHeader> _allOrders = [];
  bool _isLoading = false;

  List<OrderHeader> get userOrders => _userOrders;
  List<OrderHeader> get allOrders => _allOrders;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchUserOrders(int userId) async {
    // <-- GANTI NAMA
    _setLoading(true);
    try {
      _userOrders = await _dbService.getOrdersByUserId(userId);
    } catch (e) {
      print("Error fetching user orders: $e");
      _userOrders = [];
    }
    _setLoading(false);
  }

  Future<void> fetchAllOrders() async {
    _setLoading(true);
    try {
      _allOrders = await _dbService.getAllOrders();
    } catch (e) {
      print("Error fetching all orders: $e");
      _allOrders = [];
    }
    _setLoading(false);
  }

  Future<void> updateOrderStatus(
    int orderId,
    String newStatus, {
    int? currentUserId,
  }) async {
    _setLoading(true);
    try {
      await _dbService.updateOrderStatus(orderId, newStatus);

      await fetchAllOrders();
      if (currentUserId != null) {
        await fetchUserOrders(currentUserId);
      }
    } catch (e) {
      print("Error updating status: $e");
    }
    _setLoading(false);
  }
}
