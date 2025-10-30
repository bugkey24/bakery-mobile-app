// lib/data/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:bakery_app/models/user_model.dart';
import 'package:bakery_app/models/product_model.dart';
import 'package:bakery_app/models/cart_item_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bakery_app/models/order_model.dart';

class DatabaseService {
  static const _databaseName = "BakeryApp.db";
  static const _databaseVersion = 1;
  static const tableUsers = 'users';
  static const tableProducts = 'products';
  static const tableTransactions = 'transactions';
  static const tableTransactionDetails = 'transaction_details';

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    print("Executing _onCreate: Creating tables and minimal seed data...");

    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin', 'buyer'))
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, price INTEGER NOT NULL
      )
    '''); // <-- image_path DIHAPUS
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, total_price INTEGER NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL, status TEXT NOT NULL DEFAULT 'Pending', order_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableTransactionDetails (
        id INTEGER PRIMARY KEY AUTOINCREMENT, transaction_id INTEGER NOT NULL, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL, price_at_purchase INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES $tableTransactions (id), FOREIGN KEY (product_id) REFERENCES $tableProducts (id)
      )
    ''');

    // Insert Data Minimal
    await db.rawInsert('''
      INSERT INTO $tableUsers (username, password, role) VALUES ('admin', 'admin123', 'admin')
    ''');
    await db.rawInsert('''
      INSERT INTO $tableUsers (username, password, role) VALUES ('buyer', 'buyer123', 'buyer')
    ''');
    // Data Dummy Produk
    await db.rawInsert('''
      INSERT INTO $tableProducts (name, description, price)
      VALUES ('Sample Bread', 'Just a sample item', 10000)
    ''');

    print("_onCreate finished.");
  }

  // --- AUTHENTICATION FUNCTIONS ---
  Future<User?> getUserByUsernameAndPassword(
    String username,
    String password,
  ) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // --- PRODUCT CRUD FUNCTIONS ---
  Future<int> createProduct(Product product) async {
    final db = await instance.database;
    return await db.insert(tableProducts, product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(tableProducts, where: 'id = ?', whereArgs: [id]);
  }

  // --- TRANSACTION FUNCTIONS ---
  Future<void> createTransaction(
    User user,
    List<CartItem> cartItems,
    int totalPrice,
    Position location,
  ) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final int transactionId = await txn.insert(tableTransactions, {
        'user_id': user.id,
        'total_price': totalPrice,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'status': 'Pending',
        'order_date': DateTime.now().toIso8601String(),
      });
      for (final item in cartItems) {
        await txn.insert(tableTransactionDetails, {
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price_at_purchase': item.product.price,
        });
      }
    });
  }

  // --- ORDER HISTORY FUNCTIONS ---
  Future<List<OrderHeader>> getOrdersByUserId(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> headersMaps = await db.query(
      tableTransactions,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
    if (headersMaps.isEmpty) return [];

    List<OrderHeader> orders = [];
    for (var headerMap in headersMaps) {
      final transactionId = headerMap['id'];
      final List<Map<String, dynamic>> detailsMaps = await db.rawQuery(
        '''
        SELECT td.quantity, td.price_at_purchase, p.name AS product_name
        FROM $tableTransactionDetails td
        INNER JOIN $tableProducts p ON td.product_id = p.id
        WHERE td.transaction_id = ?
      ''',
        [transactionId],
      );
      List<OrderDetail> details = detailsMaps
          .map((map) => OrderDetail.fromMap(map))
          .toList();
      orders.add(OrderHeader.fromMap(headerMap, details));
    }
    return orders;
  }

  Future<List<OrderHeader>> getAllOrders() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> headersMaps = await db.rawQuery('''
      SELECT t.id, t.total_price, t.status, t.order_date, t.latitude, t.longitude, u.username AS buyer_username
      FROM $tableTransactions t
      INNER JOIN $tableUsers u ON t.user_id = u.id
      ORDER BY t.order_date DESC
    ''');
    if (headersMaps.isEmpty) return [];

    List<OrderHeader> orders = [];
    for (var headerMap in headersMaps) {
      final transactionId = headerMap['id'];
      final List<Map<String, dynamic>> detailsMaps = await db.rawQuery(
        '''
        SELECT td.quantity, td.price_at_purchase, p.name AS product_name
        FROM $tableTransactionDetails td
        INNER JOIN $tableProducts p ON td.product_id = p.id
        WHERE td.transaction_id = ?
      ''',
        [transactionId],
      );
      List<OrderDetail> details = detailsMaps
          .map((map) => OrderDetail.fromMap(map))
          .toList();
      orders.add(OrderHeader.fromMap(headerMap, details));
    }
    return orders;
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await instance.database;
    await db.update(
      tableTransactions,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}
