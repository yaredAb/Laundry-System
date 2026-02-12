import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/utils/payment_helper.dart';
import 'package:laundry_pos/screens/recept_screen.dart';
import 'package:laundry_pos/service/order_service.dart';

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

  void _loadOrderDetails() async {
    final data = await OrderService.loadOrderDetails(widget.orderId);

    setState(() {
      order = data['order'];
      items = data['items'];
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

    OrderService.updateStatus(newStatus, widget.orderId);

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
    final newPaid = (order!['paid'] as num).toDouble() + amount;
    final total = (order!['total'] as num).toDouble();

    if (newPaid > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment exceeds total amount")),
      );
      return;
    }

    final status = calculateStatus(newPaid, total);

    await OrderService.appPayment(newPaid, status, order!['id']);

    _loadOrderDetails();
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

  void _showDeleteDialogue() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              OrderService.deleteOrder(widget.orderId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // void _showOrderInfo() {
  //   final _statusEditingController = TextEditingController();
  //   _statusEditingController.text = order!['status'];

  //   final orderItems = items;

  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Edit an Order'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: _statusEditingController,
  //             decoration: const InputDecoration(labelText: 'Status'),
  //           ),
  //           Row(children: [Container()]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _deleteOrder() async {
    final db = await AppDatabase.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [widget.orderId]);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Order Details...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final total = (order!['total'] as num).toDouble();
    final paid = (order!['paid'] as num).toDouble();
    final balance = total - paid;
    final paymentStatus = PaymentHelper.calculatePaymentStatus(
      paid: paid,
      total: total,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Order #${order!['order_number']}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(order!['status'], large: true),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Print Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceptScreen(orderId: widget.orderId),
                  ),
                );
              },
              icon: const Icon(Icons.print),
              tooltip: 'Print Receipt',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 32,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order!['customer_name'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          order!['phone'] ?? 'No phone',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Order Date: ${_formatDate(order!['created_at'])}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_laundry_service,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Service: ${order!['service_type'] ?? 'Standard'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons for Received orders
                        if (order!['status'] == 'Received') ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement edit
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Color(0xFF2196F3),
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(color: Color(0xFF2196F3)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF2196F3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: _showDeleteDialogue,
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Order Items Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Items List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 24),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            return Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['item_name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Unit Price: ${_formatCurrency(item['price'])} ETB',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '× ${item['quantity']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  '${_formatCurrency(item['total'])} ETB',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF009688),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const Divider(height: 32),

                        // Payment Summary
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Payment Summary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPaymentSummaryRow(
                                    'Subtotal',
                                    _formatCurrency(total),
                                    isBold: false,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPaymentSummaryRow(
                                    'Service Fee',
                                    _formatCurrency(0),
                                    isBold: false,
                                    color: Colors.grey.shade600,
                                  ),
                                  const Divider(height: 16),
                                  _buildPaymentSummaryRow(
                                    'Total Amount',
                                    _formatCurrency(total),
                                    isBold: true,
                                    fontSize: 18,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPaymentSummaryRow(
                                    'Paid Amount',
                                    _formatCurrency(paid),
                                    isBold: true,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPaymentSummaryRow(
                                    'Balance',
                                    _formatCurrency(balance),
                                    isBold: true,
                                    color: balance > 0
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontSize: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              paymentStatus,
                                            ).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getPaymentStatusIcon(
                                              paymentStatus,
                                            ),
                                            size: 16,
                                            color: _getStatusColor(
                                              paymentStatus,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Payment Status',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      paymentStatus,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(paymentStatus),
                                      ),
                                    ),
                                    if (balance > 0) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _showAddPaymentDialogue,
                                          icon: const Icon(Icons.payment),
                                          label: const Text('Add Payment'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Status Update Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Builder(
                      builder: (context) {
                        final nextStatus = getNextStatus(order!['status']);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.sync_alt,
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Order Status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Status Timeline
                            Row(
                              children: [
                                _buildStatusStep(
                                  'Received',
                                  isCompleted: _isStatusCompleted(
                                    order!['status'],
                                    'Received',
                                  ),
                                  isActive: order!['status'] == 'Received',
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color:
                                        _isStatusCompleted(
                                              order!['status'],
                                              'Processing',
                                            ) ||
                                            order!['status'] == 'Processing' ||
                                            order!['status'] == 'Ready' ||
                                            order!['status'] == 'Delivered'
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                _buildStatusStep(
                                  'Processing',
                                  isCompleted: _isStatusCompleted(
                                    order!['status'],
                                    'Processing',
                                  ),
                                  isActive: order!['status'] == 'Processing',
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color:
                                        _isStatusCompleted(
                                              order!['status'],
                                              'Ready',
                                            ) ||
                                            order!['status'] == 'Ready' ||
                                            order!['status'] == 'Delivered'
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                _buildStatusStep(
                                  'Ready',
                                  isCompleted: _isStatusCompleted(
                                    order!['status'],
                                    'Ready',
                                  ),
                                  isActive: order!['status'] == 'Ready',
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: order!['status'] == 'Delivered'
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                _buildStatusStep(
                                  'Delivered',
                                  isCompleted: order!['status'] == 'Delivered',
                                  isActive: order!['status'] == 'Delivered',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            if (nextStatus != null) ...[
                              const Divider(),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Next Step',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Mark order as $nextStatus',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (paymentStatus != 'Paid' &&
                                          nextStatus == 'Delivered')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning,
                                                size: 16,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Payment required',
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(width: 16),
                                      ElevatedButton.icon(
                                        onPressed:
                                            nextStatus == 'Delivered' &&
                                                paymentStatus != 'Paid'
                                            ? null
                                            : () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text(
                                                      'Confirm Status Change',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to mark this order as $nextStatus?',
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  _getStatusColor(
                                                                    nextStatus,
                                                                  ),
                                                            ),
                                                        child: Text(
                                                          'Mark as $nextStatus',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  _updateStatus(nextStatus);
                                                }
                                              },
                                        icon: Icon(_getStatusIcon(nextStatus)),
                                        label: Text('Mark as $nextStatus'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _getStatusColor(
                                            nextStatus,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildStatusChip(String status, {bool large = false}) {
    Color color = _getStatusColor(status);
    IconData icon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(large ? 20 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 18 : 14, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: large ? 15 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(
    String label, {
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? _getStatusColor(label)
                : Colors.grey.shade200,
            border: Border.all(
              color: isActive
                  ? Colors.white
                  : isCompleted
                  ? _getStatusColor(label)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _getStatusColor(label).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted || isActive
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    label[0],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? _getStatusColor(label) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryRow(
    String label,
    String amount, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize - 2,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? Colors.grey.shade700,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic value) {
    final num number =
        (value is String ? double.tryParse(value) ?? 0 : value) as num;
    return number.toStringAsFixed(2);
  }

  bool _isStatusCompleted(String currentStatus, String statusToCheck) {
    const statusOrder = ['Received', 'Processing', 'Ready', 'Delivered'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final checkIndex = statusOrder.indexOf(statusToCheck);
    return checkIndex < currentIndex;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.blue;
      case 'Processing':
        return Colors.orange;
      case 'Ready':
        return Colors.green;
      case 'Delivered':
        return Colors.teal;
      case 'Cancelled':
        return Colors.red;
      case 'Paid':
        return Colors.green;
      case 'Partially Paid':
        return Colors.orange;
      case 'Unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Received':
        return Icons.receipt_outlined;
      case 'Processing':
        return Icons.autorenew;
      case 'Ready':
        return Icons.check_circle_outline;
      case 'Delivered':
        return Icons.local_shipping;
      case 'Cancelled':
        return Icons.cancel_outlined;
      case 'Paid':
        return Icons.payment;
      case 'Partially Paid':
        return Icons.upcoming;
      case 'Unpaid':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Partially Paid':
        return Icons.upcoming;
      case 'Unpaid':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }
}
