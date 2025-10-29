// lib/data/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// <--- BARU: Import model yang kita buat
import 'package:bakery_app/models/user_model.dart';

class DatabaseService {
  // Database name and version
  static const _databaseName = "BakeryApp.db";
  static const _databaseVersion = 1;

  // Table Names
  static const tableUsers = 'users';
  static const tableProducts = 'products';
  static const tableTransactions = 'transactions';
  static const tableTransactionDetails = 'transaction_details';

  // --- Singleton Pattern ---
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  // Only allow a single open database connection
  static Database? _database;

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Database Initialization ---
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // --- Table Creation (Schema) ---
  Future _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'buyer'))
      )
    ''');

    // Products Table
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price INTEGER NOT NULL,
        image_path TEXT 
      )
    ''');

    // Transactions Table (Header)
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        order_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers (id)
      )
    ''');

    // Transaction Details Table (Line Items)
    await db.execute('''
      CREATE TABLE $tableTransactionDetails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price_at_purchase INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES $tableTransactions (id),
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id)
      )
    ''');

    // --- INITIAL DATA (SEEDING) ---

    // Create 1 Admin user
    await db.rawInsert('''
      INSERT INTO $tableUsers (username, password, role) 
      VALUES ('admin', 'admin123', 'admin')
    ''');

    // Create 1 Buyer user
    await db.rawInsert('''
      INSERT INTO $tableUsers (username, password, role) 
      VALUES ('buyer', 'buyer123', 'buyer')
    ''');

    // Create some dummy products
    await db.rawInsert('''
      INSERT INTO $tableProducts (name, description, price, image_path) 
      VALUES ('White Bread', 'Whole wheat white bread', 15000, 'assets/images/white_bread.png')
    ''');

    await db.rawInsert('''
      INSERT INTO $tableProducts (name, description, price, image_path) 
      VALUES ('Doughnut', 'Potato doughnut with powdered sugar', 5000, 'assets/images/doughnut.png')
    ''');

    await db.rawInsert('''
      INSERT INTO $tableProducts (name, description, price, image_path) 
      VALUES ('Croissant', 'Premium butter croissant', 12000, 'assets/images/croissant.png')
    ''');
  }

  // --- (AKHIR DARI FUNGSI _onCreate) ---

  // ===================================================================
  // <--- FUNGSI BARU UNTUK OTENTIKASI (DARI LANGKAH SEBELUMNYA) --->
  // ===================================================================

  /// Mengambil user berdasarkan username dan password.
  /// Mengembalikan objek [User] jika ditemukan, atau [null] jika tidak.
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

    if (maps.isNotEmpty) {
      // Jika user ditemukan, konversi Map menjadi objek User
      return User.fromMap(maps.first);
    } else {
      // Jika tidak ditemukan, kembalikan null
      return null;
    }
  }

  /// Mengambil user berdasarkan ID mereka.
  /// Penting untuk memeriksa sesi yang tersimpan di SharedPreferences.
  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // --- (KITA AKAN TAMBAHKAN FUNGSI CRUD PRODUK DAN TRANSAKSI DI SINI NANTI) ---
}
