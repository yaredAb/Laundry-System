import 'package:laundry_pos/core/database/app_database.dart';

class CustomerService {
  static Future<List<Map<String, dynamic>>> fetchCustomer({
    String query = '',
  }) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'customers',
      orderBy: 'id DESC',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return result;
  }

  static Future<int> addCustomer(String name, {String phone = ''}) async {
    final db = await AppDatabase.database;
    int id = await db.insert('customers', {
      'name': name,
      'phone': phone,
      'registered_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  static void deleteCustomer(int id) async {
    final db = await AppDatabase.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>> getCustomer(int id) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.first;
  }
}
