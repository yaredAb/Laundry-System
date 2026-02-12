import 'package:laundry_pos/core/database/app_database.dart';

class OrderItemsService {
  static Future<List<Map<String, dynamic>>> fetchItems(int orderId) async {
    final db = await AppDatabase.database;

    final itemResult = await db.rawQuery(
      '''
      SELECT 
        i.name AS item_name,
        i.price,
        oi.quantity,
        (i.price * oi.quantity) AS total
      FROM order_items oi
      JOIN items i ON oi.item_id = i.id
      WHERE oi.order_id = ?
    ''',
      [orderId],
    );

    return itemResult;
  }

  static Future<void> saveItem(int orderId, int itemId, int quantity) async {
    final db = await AppDatabase.database;
    await db.insert('order_items', {
      'order_id': orderId,
      'item_id': itemId,
      'quantity': quantity,
    });
  }
}
