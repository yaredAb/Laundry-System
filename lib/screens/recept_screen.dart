import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';

class ReceptScreen extends StatefulWidget {
  final int orderId;
  const ReceptScreen({super.key, required this.orderId});

  @override
  State<ReceptScreen> createState() => _ReceptScreenState();
}

class _ReceptScreenState extends State<ReceptScreen> {
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Recipt')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Maya Laundry',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('📍 Addis Ababa'),
                  Divider(),
                ],
              ),
            ),

            Text('Order #: ${order!['order_number']}'),
            Text('Customer: ${order!['customer_name']}'),
            Text('Phone: ${order!['customer_phone']}'),
            Text('Date: ${order!['created_at']}'),
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

            ...items.map(
              (i) => Row(
                children: [
                  Expanded(child: Text(i['item_name'])),
                  Text('${i['quantity']}'),
                  SizedBox(width: 10),
                  Text('${i['price']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
