import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('codecrave.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        profileImage TEXT,
        role TEXT DEFAULT 'user',
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        vendorId INTEGER NOT NULL,
        stockQuantity INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (vendorId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create default admin user
    await _createDefaultAdmin(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add role column if upgrading from version 1
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');
      await _createDefaultAdmin(db);
    }
    if (oldVersion < 3) {
      // Create products table if upgrading from version 2
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL,
          category TEXT NOT NULL,
          colorValue INTEGER NOT NULL,
          vendorId INTEGER NOT NULL,
          stockQuantity INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          FOREIGN KEY (vendorId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add stockQuantity column if products table exists without it
      try {
        await db.execute('ALTER TABLE products ADD COLUMN stockQuantity INTEGER DEFAULT 0');
      } catch (e) {
        // Column might already exist, ignore error
        print('Note: stockQuantity column may already exist: $e');
      }
    }
    if (oldVersion < 5) {
      // Add isActive column to users table
      try {
        await db.execute('ALTER TABLE users ADD COLUMN isActive INTEGER DEFAULT 1');
      } catch (e) {
        // Column might already exist, ignore error
        print('Note: isActive column may already exist: $e');
      }
    }
  }

  Future<void> _createDefaultAdmin(Database db) async {
    // Check if admin already exists
    final adminExists = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@codecrave.com'],
    );

    if (adminExists.isEmpty) {
      // Create default admin user
      final adminUser = User(
        email: 'admin@codecrave.com',
        password: _hashPassword('admin123'),
        fullName: 'Admin',
        phone: '0000000000',
        address: 'Admin Office',
        role: 'admin',
      );

      await db.insert('users', adminUser.toMap());
    }

    // Create default vendor accounts if they don't exist
    await _createDefaultVendors(db);
  }

  Future<void> _createDefaultVendors(Database db) async {
    // List of default vendors to create
    final defaultVendors = [
      {
        'email': 'vendor1@codecrave.com',
        'password': 'vendor123',
        'fullName': 'John\'s Restaurant',
        'phone': '1234567890',
        'address': '123 Main Street, City',
      },
      {
        'email': 'vendor2@codecrave.com',
        'password': 'vendor123',
        'fullName': 'Maria\'s Kitchen',
        'phone': '0987654321',
        'address': '456 Oak Avenue, Town',
      },
      // Add more vendors here as needed
    ];

    for (var vendorData in defaultVendors) {
      // Check if vendor already exists
      final vendorExists = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [vendorData['email']],
      );

      if (vendorExists.isEmpty) {
        // Create vendor user
        final vendorUser = User(
          email: vendorData['email']!,
          password: _hashPassword(vendorData['password']!),
          fullName: vendorData['fullName']!,
          phone: vendorData['phone']!,
          address: vendorData['address']!,
          role: 'vendor',
        );

        await db.insert('users', vendorUser.toMap());
      }
    }
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create user
  Future<User?> createUser(User user) async {
    final db = await database;

    try {
      // Hash password before storing
      final hashedUser = user.copyWith(
        password: _hashPassword(user.password),
      );

      final id = await db.insert(
        'users',
        hashedUser.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return hashedUser.copyWith(id: id);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Login user
  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await database;

    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // Get all vendors
  Future<List<User>> getAllVendors() async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['vendor'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Toggle vendor active status
  Future<bool> toggleVendorStatus(int vendorId, bool isActive) async {
    final db = await database;

    try {
      await db.update(
        'users',
        {'isActive': isActive ? 1 : 0},
        where: 'id = ? AND role = ?',
        whereArgs: [vendorId, 'vendor'],
      );
      return true;
    } catch (e) {
      print('Error toggling vendor status: $e');
      return false;
    }
  }

  // Get all riders
  Future<List<User>> getAllRiders() async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['rider'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Toggle rider active status
  Future<bool> toggleRiderStatus(int riderId, bool isActive) async {
    final db = await database;

    try {
      await db.update(
        'users',
        {'isActive': isActive ? 1 : 0},
        where: 'id = ? AND role = ?',
        whereArgs: [riderId, 'rider'],
      );
      return true;
    } catch (e) {
      print('Error toggling rider status: $e');
      return false;
    }
  }

  // ============ PRODUCT OPERATIONS ============

  // Create product
  Future<Product?> createProduct(Product product) async {
    final db = await database;

    try {
      final id = await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return product.copyWith(id: id);
    } catch (e) {
      print('Error creating product: $e');
      return null;
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    final db = await database;

    final maps = await db.query('products', where: 'isActive = ?', whereArgs: [1]);

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Get products by vendor
  Future<List<Product>> getProductsByVendor(int vendorId) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'vendorId = ?',
      whereArgs: [vendorId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'category = ? AND isActive = ?',
      whereArgs: [category, 1],
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Update product
  Future<int> updateProduct(Product product) async {
    final db = await database;

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<int> deleteProduct(int id) async {
    final db = await database;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update product stock
  Future<bool> updateProductStock(int productId, int quantity) async {
    final db = await database;

    try {
      // Get current stock
      final maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );

      if (maps.isEmpty) return false;

      final product = Product.fromMap(maps.first);
      final newStock = product.stockQuantity - quantity;

      if (newStock < 0) return false; // Not enough stock

      // Update stock
      await db.update(
        'products',
        {'stockQuantity': newStock},
        where: 'id = ?',
        whereArgs: [productId],
      );

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
