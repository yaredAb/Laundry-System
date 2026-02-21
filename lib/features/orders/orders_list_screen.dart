import 'package:flutter/material.dart';
import 'package:laundry_pos/features/orders/order_detail_screen.dart';
import 'package:laundry_pos/service/order_service.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  String _selectedPaymentFilter = 'All';
  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }

  void _loadOrders() async {
    final result = await OrderService.loadOrdersWithCustomer();
    setState(() {
      orders = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading orders...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Orders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Filter Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Orders',
            ),
          ),

          // Search Field
          Container(
            width: 300,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterOrders,
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                final result = await OrderService.loadOrdersWithCustomer();
                setState(() {
                  orders = result;
                  loading = false;
                });
              },
              color: Theme.of(context).colorScheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  final total = (order['total'] as num).toDouble();
                  final paid = order['paid'] != null
                      ? (order['paid'] as num).toDouble()
                      : 0.0;
                  final balance = total - paid;
                  final paymentStatus = _calculatePaymentStatus(paid, total);

                  return _buildOrderCard(order, index, balance, paymentStatus);
                },
              ),
            ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    int index,
    double balance,
    String paymentStatus,
  ) {
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isEven ? Colors.grey.shade200 : Colors.transparent,
          ),
        ),
        color: isEven ? Colors.white : Colors.grey.shade50,
        child: InkWell(
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order['id']),
              ),
            );

            if (updated == true && mounted) {
              _loadOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order['order_number']} updated'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Order Number Badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getStatusColor(order['status']).withOpacity(0.7),
                        _getStatusColor(order['status']),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(
                          order['status'],
                        ).withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(child: Icon(Icons.local_laundry_service)),
                ),
                const SizedBox(width: 20),

                // Customer & Order Details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order['customer_name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Order #${order['order_number']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(order['created_at']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (order['service_type'] != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order['service_type'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Status & Payment Info
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Payment Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentStatusColor(
                            paymentStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPaymentStatusIcon(paymentStatus),
                              size: 14,
                              color: _getPaymentStatusColor(paymentStatus),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              paymentStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getPaymentStatusColor(paymentStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Order Status Chip
                      _buildStatusChip(order['status']),
                      const SizedBox(width: 20),

                      // Divider
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 20),

                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_formatCurrency(order['total'])} ETB',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF009688),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (balance > 0)
                            Text(
                              'Balance: ${_formatCurrency(balance)} ETB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              'Paid in full',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Chevron Indicator
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'No orders match your search'
                : 'Start by creating a new order',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    IconData icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('All', _selectedStatusFilter == 'All'),
                        _buildFilterChip(
                          'Received',
                          _selectedStatusFilter == 'Received',
                        ),
                        _buildFilterChip(
                          'Processing',
                          _selectedStatusFilter == 'Processing',
                        ),
                        _buildFilterChip(
                          'Ready',
                          _selectedStatusFilter == 'Ready',
                        ),
                        _buildFilterChip(
                          'Delivered',
                          _selectedStatusFilter == 'Delivered',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          'All',
                          _selectedPaymentFilter == 'All',
                        ),
                        _buildFilterChip(
                          'Paid',
                          _selectedPaymentFilter == 'Paid',
                        ),
                        _buildFilterChip(
                          'Partially Paid',
                          _selectedPaymentFilter == 'Partially Paid',
                        ),
                        _buildFilterChip(
                          'Unpaid',
                          _selectedPaymentFilter == 'Unpaid',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'From',
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                size: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              // TODO: Implement date picker
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'To',
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                size: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              // TODO: Implement date picker
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetFilters();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setState(() {
          if ([
            'Received',
            'Processing',
            'Ready',
            'Delivered',
          ].contains(label)) {
            _selectedStatusFilter = value ? label : 'All';
          } else if (['Paid', 'Partially Paid', 'Unpaid'].contains(label)) {
            _selectedPaymentFilter = value ? label : 'All';
          }
          _filterOrders(_searchController.text);
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: selected ? 1.5 : 1,
        ),
      ),
    );
  }

  // Helper Methods
  String _calculatePaymentStatus(double paid, double total) {
    if (paid >= total) return 'Paid';
    if (paid > 0) return 'Partially Paid';
    return 'Unpaid';
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today, ${_formatTime(date)}';
      } else if (difference == 1) {
        return 'Yesterday, ${_formatTime(date)}';
      } else if (difference < 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatCurrency(dynamic value) {
    final num number =
        (value is String ? double.tryParse(value) ?? 0 : value) as num;
    return number.toStringAsFixed(2);
  }

  void _filterOrders(String query) {
    setState(() {
      final _filteredOrders = orders.where((order) {
        final matchesSearch =
            query.isEmpty ||
            order['customer_name'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            order['order_number'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            (order['phone']?.toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                false);

        final matchesStatus =
            _selectedStatusFilter == 'All' ||
            order['status'] == _selectedStatusFilter;

        final paymentStatus = _calculatePaymentStatus(
          (order['paid'] as num?)?.toDouble() ?? 0,
          (order['total'] as num).toDouble(),
        );
        final matchesPayment =
            _selectedPaymentFilter == 'All' ||
            paymentStatus == _selectedPaymentFilter;

        return matchesSearch && matchesStatus && matchesPayment;
      }).toList();

      orders = _filteredOrders;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterOrders('');
  }

  void _resetFilters() {
    setState(() {
      _selectedStatusFilter = 'All';
      _selectedPaymentFilter = 'All';
      _filterOrders(_searchController.text);
    });
  }

  void _applyFilters() {
    _filterOrders(_searchController.text);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Recieved':
        return Colors.blue;
      case 'Washing':
        return Colors.orange;
      case 'Ready':
        return Colors.green;
      case 'Delivered':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Returns the icon for the payment status
  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Partially Paid':
        return Icons.remove_circle;
      case 'Unpaid':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Returns the icon for the order status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Received':
        return Icons.inbox;
      case 'Processing':
        return Icons.sync;
      case 'Ready':
        return Icons.check;
      case 'Delivered':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }
}
