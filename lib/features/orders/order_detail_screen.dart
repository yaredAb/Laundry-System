import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/utils/payment_helper.dart';
import 'package:laundry_pos/screens/recept_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? order;
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
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
      [widget.orderId],
    );

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
      [widget.orderId],
    );

    setState(() {
      order = orderResult.first;
      items = itemResult;
      loading = false;
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == 'Delivered' && order!['paid'] < order!['total']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot mark as Delivered. Payment pending.'),
        ),
      );
      return;
    }

    final db = await AppDatabase.database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [widget.orderId],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to $newStatus')),
    );

    //_loadOrderDetails();
    Navigator.pop(context, true);
  }

  String? getNextStatus(String current) {
    switch (current) {
      case 'Recieved':
        return 'Washing';
      case 'Washing':
        return 'Ready';
      case 'Ready':
        return 'Delivered';
      default:
        return null;
    }
  }

  String calculateStatus(double paid, double total) {
    if (paid <= 0) return 'Pending';
    if (paid < total) return 'Partial';
    return 'Paid';
  }

  Future<void> _addPayment(double amount) async {
    final db = await AppDatabase.database;

    final newPaid = (order!['paid'] as num).toDouble() + amount;
    final total = (order!['total'] as num).toDouble();

    if (newPaid > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment exceeds total amount")),
      );
      return;
    }

    final status = calculateStatus(newPaid, total);

    await db.update(
      'orders',
      {'paid': newPaid, 'payment_status': status},
      where: 'id = ?',
      whereArgs: [order!['id']],
    );

    await _loadOrderDetails();
  }

  void _showAddPaymentDialogue() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: 'ETB   ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) return;

              await _addPayment(amount);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order ${order!['order_number']}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order!['customer_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceptScreen(orderId: widget.orderId),
                      ),
                    );
                  },
                  label: const Text('Print Recept'),
                  icon: const Icon(Icons.print),
                ),
              ],
            ),
            Text(order!['phone'] ?? ''),
            const SizedBox(height: 4),
            Text('Status: ${order!['status']}'),
            Text('Date: ${order!['created_at']}'),
            const Divider(height: 30),

            //items
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['item_name']),
                    subtitle: Text(
                      '${item['price']} ETB × ${item['quantity']}',
                    ),
                    trailing: Text(
                      '${item['total']} ETB',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            //summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16)),
                Text(
                  '${order!['total']} ETB',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Paid',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order!['paid']} ETB',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order!['total'] - order!['paid']} ETB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (order!['total'] - order!['paid']) > 0
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final nextStatus = getNextStatus(order!['status']);
                final paymentStatus = PaymentHelper.calculatePaymentStatus(
                  paid: (order!['paid'] as num).toDouble(),
                  total: (order!['total'] as num).toDouble(),
                );

                if (nextStatus != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        if (paymentStatus != 'Paid')
                          ElevatedButton(
                            onPressed: _showAddPaymentDialogue,
                            child: const Text('Add Payment'),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: paymentStatus != 'Paid'
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: Text(
                                        'Change status to $nextStatus?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    _updateStatus(nextStatus);
                                  }
                                },
                          child: Text('Mark as $nextStatus'),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
