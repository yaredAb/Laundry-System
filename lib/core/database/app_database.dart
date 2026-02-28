import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'laundry.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // static Future<void> updateLastAccess() async {
  //   final db = await database;
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);

  //   final result = await db.query(
  //     'settings',
  //     where: "key = 'last_access_date'",
  //   );

  //   if (result.isNotEmpty) {
  //     String lastDateStr = result.first['value'] as String;
  //     DateTime lastDate = DateTime.parse(lastDateStr);

  //     if (lastDate.isAfter(today)) {
  //       _handleDateTampering();
  //       return;
  //     }
  //   }
  // Update last access
  //   await db.insert('settings', {
  //     'key': 'last_access_date',
  //     'value': today.toIso8601String(),
  //   }, conflictAlgorithm: ConflictAlgorithm.replace);
  // }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_name TEXT,
        store_phone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        pin TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        registered_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT,
        customer_id INTEGER,
        order_type TEXT,
        status TEXT,
        total REAL,
        paid REAL,
        payment_status TEXT,
        delivery_date TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        customer_id INTEGER,
        total REAL,
        paid REAL,
        payment_method TEXT,
        payment_status
        created_at TEXT
      )''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        item_id TEXT,
        quantity INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE subscription (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      token TEXT,
      plan_type TEXT,
      expiry_date TEXT,
      activated_date TEXT,
      is_active INTEGER DEFAULT 1,
      device_id TEXT
    )
  ''');

    // Store device ID on first install
    await db.execute('''
    CREATE TABLE device (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      device_id TEXT UNIQUE,
      trial_start_date TEXT,
      trial_end_date TEXT,
      trial_used INTEGER DEFAULT 0
    )
  ''');

    await _insertDefaultItems(db);
  }

  static Future<void> _insertDefaultItems(Database db) async {
    final items = [
      {'name': 'T-Shirt', 'price': 50.0},
      {'name': 'Pants', 'price': 70.0},
      {'name': 'Shirt', 'price': 60.0},
      {'name': 'Jacket', 'price': 120.0},
      {'name': 'Blanket', 'price': 150.0},
    ];

    for (final item in items) {
      await db.insert("items", item);
    }
  }

  static Future<bool> hasSettings() async {
    final db = await database;
    final result = await db.query('settings', limit: 1);
    return result.isNotEmpty;
  }
}
