import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/service/order_items_service.dart';

class OrderService {
  static Future<List<Map<String, dynamic>>> loadOrdersWithCustomer() async {
    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT 
        o.id, 
        o.order_number, 
        o.total, 
        o.status, 
        o.created_at, 
        c.name AS customer_name
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      ORDER BY o.created_at DESC
  ''');

    return result;
  }

  static Future<Map<String, dynamic>> loadOrderDetails(int orderId) async {
    final db = await AppDatabase.database;
    final orderResult = await db.rawQuery(
      '''
      SELECT 
        o.id, 
        o.order_number, 
        o.total, 
        o.paid,
        o.status, 
        o.payment_status,
        o.created_at, 
        c.name AS customer_name,
        c.phone AS customer_phone
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.id = ?
      ''',
      [orderId],
    );

    final itemResult = await OrderItemsService.fetchItems(orderId);

    return {
      'order': orderResult.isNotEmpty ? orderResult.first : null,
      'items': itemResult,
    };
  }

  static Future<int?> saveOrder(
    int customerId,
    String selectedService,
    DateTime deliveryDate,
  ) async {
    final db = await AppDatabase.database;

    int orderId = await db.insert('orders', {
      'order_number': DateTime.now().microsecondsSinceEpoch.toString(),
      'customer_id': customerId,
      'status': 'Recieved',
      'delivery_date': deliveryDate.toString(),
      'payment_status': 'Pending',
      'order_type': selectedService,
      'created_at': DateTime.now().toIso8601String(),
    });

    return orderId;
  }

  static Future<void> updateStatus(String newStatus, int orderId) async {
    final db = await AppDatabase.database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<void> appPayment(
    double newPaid,
    String status,
    int orderId,
  ) async {
    final db = await AppDatabase.database;
    await db.update(
      'orders',
      {'paid': newPaid, 'payment_status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static void deleteOrder(int orderId) async {
    final db = await AppDatabase.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }

  static Future<List<Map<String, dynamic>>> loadOrderByCustomer(
    int customerId,
  ) async {
    final db = await AppDatabase.database;

    final orders = await db.query(
      'orders',
      where: 'customer_id = ?',
      orderBy: 'id DESC',
      whereArgs: [customerId],
    );

    return orders;
  }
}
