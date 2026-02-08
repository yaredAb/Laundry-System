import 'package:flutter/material.dart';
import 'package:laundry_pos/components/receipt_content.dart';
import 'package:laundry_pos/core/database/app_database.dart';

class ReceiptContentFull extends StatefulWidget {
  final int orderId;
  const ReceiptContentFull({super.key, required this.orderId});

  @override
  State<ReceiptContentFull> createState() => _ReceiptContentFullState();
}

class _ReceiptContentFullState extends State<ReceiptContentFull> {
  Map<String, dynamic>? order;
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  Future<void> _loadRecept() async {
    final db = await AppDatabase.database;

    final o = await db.rawQuery(
      '''
      SELECT 
        o.id, 
        o.order_number, 
        o.total, 
        o.paid,
        o.status, 
        o.created_at, 
        c.name AS customer_name,
        c.phone AS customer_phone
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.id = ?
      ''',
      [widget.orderId],
    );

    final i = await db.rawQuery(
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
      order = o.first;
      items = i;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRecept();
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SizedBox(
        width: 280,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Maya Laundry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('📍 Addis Ababa'),
                    Divider(),
                  ],
                ),
              ),

              Text('Order #: ${order!['order_number']}'),
              Text('Customer: ${order!['customer_name']}'),
              Text('Phone: ${order!['customer_phone']}'),
              Text('Date: ${_formatDate(order!['created_at'])}'),
              const Divider(),

              Row(
                children: const [
                  Expanded(child: Text('Item')),
                  Text('Qty'),
                  SizedBox(width: 10),
                  Text('Price'),
                ],
              ),
              const Divider(),
              ReceiptContent(items: items),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order!['total']} ETB',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
