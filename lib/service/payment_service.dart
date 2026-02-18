import 'package:laundry_pos/core/database/app_database.dart';

class PaymentService {
  static Future<void> savePayment({
    required int orderId,
    required int customerId,
    required double total,
    double paid = 0,
    String paymentType = 'Cash',
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
}
