import 'package:laundry_pos/core/database/app_database.dart';

class PaymentService {
  static Future<void> savePayment({
    required int orderId,
    required int customerId,
    required double total,
    double paid = 0,
    String paymentType = 'Cash',
    String paymentStatus = 'Pending',
  }) async {
    final db = await AppDatabase.database;

    await db.insert('payments', {
      'order_id': orderId,
      'customer_id': customerId,
      'total': total,
      'paid': paid,
      'payment_method': paymentType,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> addPayment(
    int orderId,
    double paidAMount,
    String status,
  ) async {
    final db = await AppDatabase.database;

    await db.update(
      'payments',
      {'paid': paidAMount, 'payment_status': status},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
}
