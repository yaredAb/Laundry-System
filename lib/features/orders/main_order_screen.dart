import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laundry_pos/components/receipt_content_full.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/model/order_item.dart';
import 'package:laundry_pos/screens/recept_screen.dart';
import 'package:laundry_pos/service/customer_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _loadServiceItems();
  }

  Future<void> _fetchCustomers() async {
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
    final id = CustomerService.addCustomer(
      _newCustomerController.text,
      phone: _newCustomerPhone.text,
    );
    _fetchCustomers();

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
      _showErrorSnackbar('Please select a customer and add at least one item');
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
        'payment_status': 'Pending',
        'order_type': selectedService,
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

  Future<void> _shareReceipt(int orderId) async {
    final image = await _screenshotController.captureFromWidget(
      MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // Provides Theme and MediaQuery
          home: Material(
            child: Container(
              width: 250,
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Center(child: ReceiptContentFull(orderId: orderId)),
            ),
          ),
        ),
      ),
      delay: const Duration(milliseconds: 100),
    );

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/laundry_receipt_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);

    await file.writeAsBytes(image);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await Process.run('xdg-open', [filePath]);
      return;
    }

    await Share.shareXFiles([XFile(filePath)], text: 'Laundry Receipt');
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
                          onPressed: () => _shareReceipt(orderId),
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Laundry Orders",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ CUSTOMER PANEL ============
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${customers.length} total',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Customer Form Card
                        Card(
                          elevation: 0,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _newCustomerController,
                                  decoration: InputDecoration(
                                    labelText: 'Customer Name',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _newCustomerPhone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addCustomer,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Customer'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Customer List Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer List',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              onPressed: _fetchCustomers,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              iconSize: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Customer List
                        Expanded(
                          child: customers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No customers yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: customers.length,
                                  itemBuilder: (_, index) {
                                    final c = customers[index];
                                    final isSelected =
                                        selectedCustomer != null &&
                                        selectedCustomer!['id'] == c['id'];
                                    return Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      color: isSelected
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1)
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey.shade200,
                                          child: Text(
                                            (c['name'] as String)
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          c['name'],
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Text(
                                          c['phone'] ?? 'No phone',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            selectedCustomer = c;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // ============ ORDER PANEL ============
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with selected customer info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                if (selectedCustomer != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Customer: ${selectedCustomer!['name']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (selectedCustomer == null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 20,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select a customer',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Add Item Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: selectedCustomer == null
                                ? null
                                : _showItemPicker,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add Item to Order'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Order Items List
                        Expanded(
                          child: orderItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 64,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No items added',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        selectedCustomer == null
                                            ? 'Select a customer to start'
                                            : 'Click "Add Item" to begin',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: orderItems.length,
                                  itemBuilder: (_, index) {
                                    final item = orderItems[index];
                                    return Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.itemName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Unit Price: ${item.price.toStringAsFixed(2)} ETB',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${item.price.toStringAsFixed(2)} ETB',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (item.quantity > 1) {
                                                          item.quantity--;
                                                          _calculateTotal();
                                                        }
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 4,
                                                                ),
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          TextEditingController(
                                                            text: item.quantity
                                                                .toString(),
                                                          ),
                                                      onChanged: (v) {
                                                        item.quantity =
                                                            int.tryParse(v) ??
                                                            1;
                                                        _calculateTotal();
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        item.quantity++;
                                                        _calculateTotal();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              '${item.subtotal.toStringAsFixed(2)} ETB',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  orderItems.remove(item);
                                                  _calculateTotal();
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red.shade400,
                                              iconSize: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 20),

                        // Bottom Actions and Totals
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Service Selection Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_laundry_service,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Service Type:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  DropdownButton<String>(
                                    value: selectedService,
                                    items: ['Wash', 'Dry Clean', 'Iron']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getServiceColor(
                                                  s,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  color: _getServiceColor(s),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        selectedService = v!;
                                      });
                                    },
                                    underline: Container(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),

                                  // Totals
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total:',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$total ETB',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Paid:',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$paid ETB',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Save Order Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (selectedCustomer == null) {
                                      _showErrorSnackbar(
                                        'Please select a customer',
                                      );
                                      return;
                                    }
                                    if (orderItems.isEmpty) {
                                      _showErrorSnackbar(
                                        'Please add items to order',
                                      );
                                      return;
                                    }
                                    final orderId = await _saveOrder();
                                    if (orderId != null && mounted) {
                                      _showReceiptDialog(orderId);
                                    }
                                  },
                                  icon: const Icon(Icons.save_alt),
                                  label: const Text('Save Order'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for service colors
  Color _getServiceColor(String service) {
    switch (service) {
      case 'Wash':
        return Colors.blue;
      case 'Dry Clean':
        return Colors.purple;
      case 'Iron':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
