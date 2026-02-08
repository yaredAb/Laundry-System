import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/model/order_item.dart';
import 'package:laundry_pos/screens/recept_screen.dart';

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

  //Service List
  List<Map<String, dynamic>> availableItems = [];

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
    _loadServiceItems();
  }

  Future<void> _loadCustomers() async {
    final db = await AppDatabase.database;
    final result = await db.query('customers', orderBy: 'id DESC');
    setState(() {
      customers = result;
    });
  }

  Future<void> _loadServiceItems() async {
    final db = await AppDatabase.database;
    final result = await db.query("items");
    setState(() {
      availableItems = result;
    });
  }

  void _addCustomer() async {
    if (_newCustomerController.text.trim().isEmpty) return;
    final db = await AppDatabase.database;
    int id = await db.insert('customers', {
      'name': _newCustomerController.text,
      'phone': _newCustomerPhone.text,
      'registered_at': DateTime.now().toIso8601String(),
    });

    _loadCustomers();

    setState(() {
      selectedCustomer = {'id': id, 'name': _newCustomerController.text};
    });

    _newCustomerController.clear();
    _newCustomerPhone.clear();
  }

  void _addOrderItem(Map<String, dynamic> item) {
    final existing = orderItems.where((e) => e.itemId == item['id']);

    if (existing.isNotEmpty) {
      existing.first.quantity += 1;
    } else {
      orderItems.add(
        OrderItem(
          itemId: item['id'],
          itemName: item['name'],
          price: item['price'],
          quantity: 1,
        ),
      );
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    setState(() {
      total = orderItems.fold(
        0,
        (sum, item) => sum + (item.quantity * item.price),
      );
    });
  }

  Future<int?> _saveOrder() async {
    if (selectedCustomer == null || orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer and add at least one item.'),
        ),
      );
      return null;
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
          'order_id': orderId,
          'item_id': item.itemId,
          'quantity': item.quantity,
        });
      }

      setState(() {
        selectedCustomer = null;
        orderItems.clear();
        total = 0;
        paid = 0;
      });

      return orderId;
    } catch (e) {
      //handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
      return null;
    }

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text('Order saved successfully')));
  }

  void _showItemPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Item"),
        content: SizedBox(
          width: 300,
          height: 300,
          child: ListView.builder(
            itemCount: availableItems.length,
            itemBuilder: (_, index) {
              final item = availableItems[index];
              return ListTile(
                title: Text(item['name']),
                trailing: Text("${item['price']}"),
                onTap: () {
                  _addOrderItem(item);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(int orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 350, child: ReceptScreen(orderId: orderId)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          label: const Text("Share"),
                          icon: const Icon(Icons.share),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          label: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                    onPressed: _showItemPicker,
                    child: const Text('Add Item'),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (_, index) {
                        final item = orderItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.itemName)),
                              Text('${item.price} ETB'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    item.quantity = int.tryParse(v) ?? 1;
                                    _calculateTotal();
                                  },
                                ),
                              ),
                              Text('${item.subtotal}'),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    orderItems.remove(item);
                                    _calculateTotal();
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
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
                        onPressed: () async {
                          final orderId = await _saveOrder();
                          if (orderId != null) {
                            _showReceiptDialog(orderId);
                          }
                        },
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
