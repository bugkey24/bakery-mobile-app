// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:bakery_app/data/database_service.dart';
import 'package:bakery_app/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _setLoading(true);
    try {
      _products = await _dbService.getProducts();
    } catch (e) {
      print("Error fetching products: $e");
      _products = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      await _dbService.createProduct(product);
      await fetchProducts();
    } catch (e) {
      print("Error adding product: $e");
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<void> updateProduct(Product product) async {
    _setLoading(true);
    try {
      await _dbService.updateProduct(product);
      await fetchProducts();
    } catch (e) {
      print("Error updating product: $e");
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<void> deleteProduct(int id) async {
    _setLoading(true);
    try {
      await _dbService.deleteProduct(id);
      await fetchProducts();
    } catch (e) {
      print("Error deleting product: $e");
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }
}
