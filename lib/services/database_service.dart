import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

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
      version: 9,
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
        vendorName TEXT NOT NULL,
        vendorImage TEXT,
        stockQuantity INTEGER DEFAULT 0,
        imagePath TEXT,
        hasCustomization INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (vendorId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        vendorId INTEGER NOT NULL,
        riderId INTEGER,
        restaurant TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        items TEXT NOT NULL,
        customerName TEXT NOT NULL,
        deliveryAddress TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        acceptedAt TEXT,
        completedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (vendorId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (riderId) REFERENCES users (id) ON DELETE SET NULL
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
          imagePath TEXT,
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
    if (oldVersion < 6) {
      // Create orders table
      await db.execute('''
        CREATE TABLE orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          vendorId INTEGER NOT NULL,
          riderId INTEGER,
          restaurant TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          status TEXT NOT NULL,
          items TEXT NOT NULL,
          customerName TEXT NOT NULL,
          deliveryAddress TEXT NOT NULL,
          phoneNumber TEXT NOT NULL,
          paymentMethod TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          acceptedAt TEXT,
          completedAt TEXT,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (vendorId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (riderId) REFERENCES users (id) ON DELETE SET NULL
        )
      ''');
    }
    if (oldVersion < 7) {
      // Add imagePath column to products table
      try {
        await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
      } catch (e) {
        // Column might already exist, ignore error
        print('Note: imagePath column may already exist: $e');
      }
    }
    if (oldVersion < 8) {
      // Add vendorName column to products table
      try {
        await db.execute('ALTER TABLE products ADD COLUMN vendorName TEXT DEFAULT "Unknown Store"');

        // Update existing products with vendor names from users table
        final products = await db.query('products');
        for (var product in products) {
          final vendorId = product['vendorId'] as int;
          final vendorQuery = await db.query(
            'users',
            columns: ['fullName'],
            where: 'id = ?',
            whereArgs: [vendorId],
          );

          if (vendorQuery.isNotEmpty) {
            final vendorName = vendorQuery.first['fullName'] as String;
            await db.update(
              'products',
              {'vendorName': vendorName},
              where: 'id = ?',
              whereArgs: [product['id']],
            );
          }
        }
      } catch (e) {
        // Column might already exist, ignore error
        print('Note: vendorName column may already exist: $e');
      }
    }
    if (oldVersion < 9) {
      // Add vendorImage and hasCustomization columns to products table
      try {
        await db.execute('ALTER TABLE products ADD COLUMN vendorImage TEXT');
        await db.execute('ALTER TABLE products ADD COLUMN hasCustomization INTEGER DEFAULT 0');

        // Update existing products with vendor profile images from users table
        final products = await db.query('products');
        for (var product in products) {
          final vendorId = product['vendorId'] as int;
          final vendorQuery = await db.query(
            'users',
            columns: ['profileImage'],
            where: 'id = ?',
            whereArgs: [vendorId],
          );

          if (vendorQuery.isNotEmpty && vendorQuery.first['profileImage'] != null) {
            final vendorImage = vendorQuery.first['profileImage'] as String;
            await db.update(
              'products',
              {'vendorImage': vendorImage},
              where: 'id = ?',
              whereArgs: [product['id']],
            );
          }
        }
      } catch (e) {
        // Columns might already exist, ignore error
        print('Note: vendorImage/hasCustomization columns may already exist: $e');
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

  // ============ ORDER OPERATIONS ============

  // Create order
  Future<Order?> createOrder(Order order) async {
    final db = await database;

    try {
      // Debug: Print order data being inserted
      print('DEBUG: Creating order with status: ${order.status}');
      print('DEBUG: Order data: ${order.toMap()}');
      
      final id = await db.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      print('DEBUG: Order inserted with ID: $id');
      return order.copyWith(id: id);
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get all orders
  Future<List<Order>> getAllOrders() async {
    final db = await database;

    final maps = await db.query('orders', orderBy: 'createdAt DESC');

    return maps.map((map) => Order.fromMap(map)).toList();
  }

  // Get orders by user
  Future<List<Order>> getOrdersByUser(int userId) async {
    final db = await database;

    final maps = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Order.fromMap(map)).toList();
  }

  // Get orders by vendor
  Future<List<Order>> getOrdersByVendor(int vendorId) async {
    final db = await database;

    final maps = await db.query(
      'orders',
      where: 'vendorId = ?',
      whereArgs: [vendorId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Order.fromMap(map)).toList();
  }

  // Get orders by rider
  Future<List<Order>> getOrdersByRider(int riderId) async {
    final db = await database;

    final maps = await db.query(
      'orders',
      where: 'riderId = ?',
      whereArgs: [riderId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Order.fromMap(map)).toList();
  }

  // Get pending orders (for riders to accept)
  Future<List<Order>> getPendingOrders() async {
    final db = await database;

    final maps = await db.query(
      'orders',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'ready'],
      orderBy: 'createdAt DESC',
    );

    // Debug: Print raw database results
    print('DEBUG: Raw database query returned ${maps.length} orders');
    for (var map in maps) {
      print('DEBUG: Raw order - ID: ${map['id']}, Status: ${map['status']}, Customer: ${map['customerName']}');
    }

    return maps.map((map) => Order.fromMap(map)).toList();
  }

  // Update order
  Future<int> updateOrder(Order order) async {
    final db = await database;

    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // Update order status
  Future<bool> updateOrderStatus(int orderId, String newStatus, {int? riderId}) async {
    final db = await database;

    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
      };

      if (newStatus == 'accepted' || newStatus == 'delivering') {
        updateData['acceptedAt'] = DateTime.now().toIso8601String();
        if (riderId != null) {
          updateData['riderId'] = riderId;
        }
      }

      if (newStatus == 'completed' || newStatus == 'cancelled') {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      await db.update(
        'orders',
        updateData,
        where: 'id = ?',
        whereArgs: [orderId],
      );

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Assign rider to order
  Future<bool> assignRiderToOrder(int orderId, int riderId) async {
    final db = await database;

    try {
      await db.update(
        'orders',
        {
          'riderId': riderId,
          'status': 'accepted',
          'acceptedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      return true;
    } catch (e) {
      print('Error assigning rider to order: $e');
      return false;
    }
  }

  // Delete order
  Future<int> deleteOrder(int id) async {
    final db = await database;

    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get order by ID
  Future<Order?> getOrderById(int id) async {
    final db = await database;

    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
