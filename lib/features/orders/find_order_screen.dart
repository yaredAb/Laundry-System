import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/features/orders/order_detail_screen.dart';

class FindOrderScreen extends StatefulWidget {
  const FindOrderScreen({super.key});

  @override
  State<FindOrderScreen> createState() => _FindOrderScreenState();
}

class _FindOrderScreenState extends State<FindOrderScreen> {
  final TextEditingController _orderNumberController = TextEditingController();
  bool loading = false;

  Future<void> _findOrder() async {
    final orderNo = _orderNumberController.text.trim();

    if (orderNo.isEmpty) return;

    setState(() => loading = true);

    final db = await AppDatabase.database;
    final result = await db.query(
      'orders',
      where: 'order_number = ?',
      whereArgs: [orderNo],
      limit: 1,
    );

    setState(() => loading = false);

    if (result.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order not found.')));

      return;
    }

    final orderId = result.first['id'] as int;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Order')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _orderNumberController,
              decoration: InputDecoration(
                labelText: 'Order Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _findOrder,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('FIND ORDER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
