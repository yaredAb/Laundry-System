import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/model/order_item.dart';

class MainOrderScreen extends StatefulWidget {
  const MainOrderScreen({super.key});

  @override
  State<MainOrderScreen> createState() => _MainOrderScreenState();
}

class _MainOrderScreenState extends State<MainOrderScreen> {
  //customers
  List<Map<String, dynamic>> customers = [];
  Map<String, dynamic>? selectedCustomer;
  final _newCustomerController = TextEditingController();
  final _newCustomerPhone = TextEditingController();

  //order items
  List<OrderItem> orderItems = [];

  //Service and due date
  String selectedService = 'Wash';
  DateTime? dueDate = DateTime.now();

  //payment
  double total = 0;
  double paid = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final db = await AppDatabase.database;
    final result = await db.query('customers', orderBy: 'id DESC');
    setState(() {
      customers = result;
    });
  }

  void _addCustomer() async {
    if (_newCustomerController.text.trim().isEmpty) return;
    final db = await AppDatabase.database;
    int id = await db.insert('customers', {
      'name': _newCustomerController.text,
      'phone': _newCustomerPhone.text,
    });

    _loadCustomers();

    setState(() {
      selectedCustomer = {'id': id, 'name': _newCustomerController.text};
    });

    _newCustomerController.clear();
    _newCustomerPhone.clear();
  }

  void _addOrderItem() {
    setState(() {
      orderItems.add(OrderItem(itemName: 'T-shirt', quantity: 1, price: 0.0));
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    total = orderItems.fold(
      0,
      (sum, item) => sum + (item.quantity * item.price),
    );
  }

  Future<void> _saveOrder() async {
    if (selectedCustomer == null || orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer and add at least one item.'),
        ),
      );
      return;
    }

    final db = await AppDatabase.database;
    try {
      int orderId = await db.insert('orders', {
        'order_number': DateTime.now().microsecondsSinceEpoch.toString(),
        'customer_id': selectedCustomer!['id'],
        'total': total,
        'paid': paid,
        'status': 'Recieved',
        'created_at': DateTime.now().toIso8601String(),
      });

      for (var item in orderItems) {
        await db.insert('order_items', {
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'order_id': orderId,
          'item_name': item.itemName,
          'quantity': item.quantity,
          'price': item.price,
        });
      }
    } catch (e) {
      //handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order saved successfully')));

    setState(() {
      selectedCustomer = null;
      orderItems.clear();
      total = 0;
      paid = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laundry Orders")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            //customer pannel
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newCustomerController,
                    decoration: InputDecoration(
                      labelText: 'Cusomer Name',
                      // suffixIcon: IconButton(
                      //   onPressed: _addCustomer,
                      //   icon: const Icon(Icons.add),
                      // ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newCustomerPhone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      // suffixIcon: IconButton(
                      //   onPressed: _addCustomer,
                      //   icon: const Icon(Icons.add),
                      // ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addCustomer,
                    child: Text("Add Customer"),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (_, index) {
                        final c = customers[index];
                        return ListTile(
                          title: Text(c['name']),
                          selected:
                              selectedCustomer != null &&
                              selectedCustomer!['id'] == c['id'],
                          onTap: () {
                            setState(() {
                              selectedCustomer = c;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            //order items and details
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: _addOrderItem,
                    child: const Text('Add Item'),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (_, index) {
                        final item = orderItems[index];
                        return ListTile(
                          title: Text('${item.itemName} x${item.quantity}'),
                          trailing: Text('${item.price * item.quantity} ETB'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedService,
                        items: ['Wash', 'Dry Clean', 'Iron']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedService = v!;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _saveOrder,
                        child: const Text('Save Order'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Total: $total, Paid: $paid'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
