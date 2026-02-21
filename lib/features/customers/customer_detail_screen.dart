import 'package:flutter/material.dart';
import 'package:laundry_pos/features/orders/main_order_screen.dart';
import 'package:laundry_pos/features/orders/order_detail_screen.dart';
import 'package:laundry_pos/service/customer_service.dart';
import 'package:laundry_pos/service/order_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;
  final Map<String, dynamic> customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic> customerData = {};
  List<Map<String, dynamic>> orderData = [];
  bool isLoading = true;

  // Define a random color for the customer avatar
  final Color randomColor = Colors.blueAccent;

  Future<void> _fetchCustomerInfo() async {
    final result = await CustomerService.getCustomer(widget.customerId);
    setState(() {
      customerData = result;
    });
  }

  Future<void> _loadOrderData() async {
    final result = await OrderService.loadOrderByCustomer(widget.customerId);
    setState(() {
      orderData = result;
    });
  }

  void _loadCustomerData() async {
    await _fetchCustomerInfo();
    await _loadOrderData();

    setState(() {
      isLoading = false;
    });
  }

  // ============ SAMPLE CUSTOMER DATA ============
  // This would normally come from your database
  final Map<String, dynamic> _sampleCustomer = {
    'id': 1001,
    'name': 'Abebe Kebede',
    'phone': '+251 912 345 678',
    'email': 'abebe.kebede@email.com',
    'address': 'Bole Road, Addis Ababa',
    'member_since': '2023-08-15',
    'total_orders': 24,
    'total_spent': 8750.50,
    'pending_balance': 350.00,
    'last_visit': '2024-03-15 14:30',
    'customer_type': 'VIP',
    'preferred_service': 'Dry Cleaning',
  };

  // ============ SAMPLE ORDER HISTORY ============
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 1001,
      'order_number': 'ORD-2024-0042',
      'date': '2024-03-15',
      'time': '14:30',
      'total': 450.00,
      'paid': 450.00,
      'status': 'Delivered',
      'items': [
        {'name': 'Business Suit', 'quantity': 2, 'price': 150.00},
        {'name': 'Dress Shirt', 'quantity': 3, 'price': 50.00},
      ],
      'service': 'Dry Cleaning',
    },
    {
      'id': 1002,
      'order_number': 'ORD-2024-0038',
      'date': '2024-03-12',
      'time': '10:15',
      'total': 320.00,
      'paid': 320.00,
      'status': 'Delivered',
      'items': [
        {'name': 'Pants', 'quantity': 4, 'price': 45.00},
        {'name': 'T-Shirt', 'quantity': 2, 'price': 70.00},
      ],
      'service': 'Wash & Iron',
    },
    {
      'id': 1003,
      'order_number': 'ORD-2024-0025',
      'date': '2024-03-08',
      'time': '16:45',
      'total': 680.00,
      'paid': 500.00,
      'status': 'Processing',
      'items': [
        {'name': 'Winter Jacket', 'quantity': 2, 'price': 250.00},
        {'name': 'Sweater', 'quantity': 3, 'price': 60.00},
      ],
      'service': 'Dry Cleaning',
    },
    {
      'id': 1004,
      'order_number': 'ORD-2024-0019',
      'date': '2024-03-05',
      'time': '11:20',
      'total': 210.00,
      'paid': 210.00,
      'status': 'Ready',
      'items': [
        {'name': 'Dress Shirt', 'quantity': 3, 'price': 50.00},
        {'name': 'Tie', 'quantity': 2, 'price': 30.00},
      ],
      'service': 'Iron Only',
    },
    {
      'id': 1005,
      'order_number': 'ORD-2024-0012',
      'date': '2024-03-01',
      'time': '09:00',
      'total': 890.00,
      'paid': 890.00,
      'status': 'Delivered',
      'items': [
        {'name': 'Bed Sheet Set', 'quantity': 2, 'price': 180.00},
        {'name': 'Curtains', 'quantity': 3, 'price': 150.00},
        {'name': 'Duvet Cover', 'quantity': 2, 'price': 85.00},
      ],
      'service': 'Wash & Iron',
    },
  ];

  // ============ SAMPLE PAYMENT HISTORY ============
  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'id': 1,
      'date': '2024-03-15',
      'time': '14:30',
      'amount': 450.00,
      'method': 'Cash',
      'order_id': 'ORD-2024-0042',
      'reference': 'CASH-001',
    },
    {
      'id': 2,
      'date': '2024-03-12',
      'time': '10:15',
      'amount': 320.00,
      'method': 'Mobile Money',
      'order_id': 'ORD-2024-0038',
      'reference': 'MM-889922',
    },
    {
      'id': 3,
      'date': '2024-03-08',
      'time': '16:45',
      'amount': 500.00,
      'method': 'Card',
      'order_id': 'ORD-2024-0025',
      'reference': 'CARD-4455',
    },
    {
      'id': 4,
      'date': '2024-03-01',
      'time': '09:00',
      'amount': 890.00,
      'method': 'Bank Transfer',
      'order_id': 'ORD-2024-0012',
      'reference': 'TRF-112233',
    },
  ];

  String _selectedTab = 'overview';

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    // Use sample data, but in real app you'd use widget.customer
    final customer = _sampleCustomer;
    final memberSince = DateTime.parse(customer['member_since']);
    final now = DateTime.now();
    final membershipDays = now.difference(memberSince).inDays;
    final membershipYears = (membershipDays / 365).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: randomColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_outline, color: randomColor),
            ),
            const SizedBox(width: 12),
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Edit Customer Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _editCustomer,
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF2196F3)),
              tooltip: 'Edit Customer',
            ),
          ),
          const SizedBox(width: 8),
          // New Order Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _createNewOrder,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.teal),
              tooltip: 'Create New Order',
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // ============ LEFT SIDEBAR - CUSTOMER PROFILE ============
                Container(
                  width: 380,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Profile Header with Cover
                      const SizedBox(height: 60),

                      // Customer Name and Badge
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  customerData['name'],
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.amber,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer['customer_type'],
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Member Since
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Member since',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        '${memberSince.day}/${memberSince.month}/${memberSince.year}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$membershipYears years',
                                      style: const TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact Information
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      color: Colors.teal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        customerData['phone'] ?? 'No Phone',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Email
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.email,
                                      color: Color(0xFF2196F3),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        customerData['email'] ?? 'No Email',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Address
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        customerData['address'] ?? 'No Address',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _editCustomer,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _createNewOrder,
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'New Order',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: const Color(0xFF2196F3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ============ RIGHT CONTENT - STATS AND HISTORY ============
                Expanded(
                  child: Container(
                    color: Colors.grey.shade50,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Message
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Dashboard',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Color(0xFF2196F3),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last visit: ${customer['last_visit']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Statistics Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.shopping_bag_outlined,
                                  label: 'Total Orders',
                                  value: '${orderData.length}',
                                  subtitle: 'All time',
                                  color: Colors.blue,
                                  change: '+12%',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.attach_money,
                                  label: 'Total Spent',
                                  value:
                                      '${customer['total_spent'].toStringAsFixed(2)} ETB',
                                  subtitle: 'Lifetime value',
                                  color: Colors.green,
                                  change: '+8%',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.account_balance_wallet,
                                  label: 'Pending Balance',
                                  value:
                                      '${customer['pending_balance'].toStringAsFixed(2)} ETB',
                                  subtitle: 'Due amount',
                                  color: customer['pending_balance'] > 0
                                      ? Colors.orange
                                      : Colors.green,
                                  change: customer['pending_balance'] > 0
                                      ? 'Due'
                                      : 'Paid',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.favorite_outline,
                                  label: 'Preferred',
                                  value: customer['preferred_service'],
                                  subtitle: 'Favorite service',
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Tab Navigation
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTabOption(
                                  label: 'Overview',
                                  icon: Icons.dashboard_outlined,
                                  isSelected: _selectedTab == 'overview',
                                  onTap: () =>
                                      setState(() => _selectedTab = 'overview'),
                                ),
                                _buildTabOption(
                                  label: 'Order History',
                                  icon: Icons.list_alt,
                                  isSelected: _selectedTab == 'orders',
                                  onTap: () =>
                                      setState(() => _selectedTab = 'orders'),
                                ),
                                _buildTabOption(
                                  label: 'Payments',
                                  icon: Icons.payment,
                                  isSelected: _selectedTab == 'payments',
                                  onTap: () =>
                                      setState(() => _selectedTab = 'payments'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tab Content
                          if (_selectedTab == 'overview') _buildOverviewTab(),
                          if (_selectedTab == 'orders') _buildOrdersTab(),
                          if (_selectedTab == 'payments') _buildPaymentsTab(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ============ STATISTICS CARD ============
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    String? change,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: change == 'Due'
                        ? Colors.orange.withOpacity(0.1)
                        : change == 'Paid'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: change == 'Due'
                          ? Colors.orange
                          : change == 'Paid'
                          ? Colors.green
                          : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ============ TAB OPTION ============
  Widget _buildTabOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ OVERVIEW TAB ============
  Widget _buildOverviewTab() {
    final customer = _sampleCustomer;

    return Column(
      children: [
        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.receipt_outlined,
                title: 'Recent Orders',
                subtitle: 'View order history',
                color: Colors.blue,
                onTap: () => setState(() => _selectedTab = 'orders'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.payment,
                title: 'Payment History',
                subtitle: 'View transactions',
                color: Colors.teal,
                onTap: () => setState(() => _selectedTab = 'payments'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.local_laundry_service,
                title: 'New Order',
                subtitle: 'Create for ${customer['name'].split(' ')[0]}',
                color: Colors.purple,
                onTap: _createNewOrder,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Recent Activity
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedTab = 'orders'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentOrders.take(3).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final order = _recentOrders[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          order['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(order['status']),
                        color: _getStatusColor(order['status']),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      order['order_number'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${order['date']} • ${order['items'].length} items',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${order['total'].toStringAsFixed(2)} ETB',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009688),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusChip(order['status']),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ ORDERS TAB ============
  Widget _buildOrdersTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildTableHeader('Order #')),
                Expanded(child: _buildTableHeader('Date')),
                Expanded(child: _buildTableHeader('Items')),
                Expanded(child: _buildTableHeader('Service')),
                Expanded(child: _buildTableHeader('Total')),
                Expanded(child: _buildTableHeader('Status')),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Order List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderData.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (_, index) {
              final order = orderData[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        order['order_number'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${order['created_at']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Text('3 items')),
                    Expanded(child: Text(order['order_service'] ?? '_')),
                    Expanded(
                      child: Text(
                        '${order['total'].toStringAsFixed(2)} ETB',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: _buildStatusChip(order['status'])),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => _viewOrder(order['id']),
                        icon: Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ PAYMENTS TAB ============
  Widget _buildPaymentsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentHistory.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (_, index) {
              final payment = _paymentHistory[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['order_id'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${payment['date']} at ${payment['time']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              payment['method'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reference',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment['reference'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${payment['amount'].toStringAsFixed(2)} ETB',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009688),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ QUICK ACTION CARD ============
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        fontSize: 13,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  // ============ HELPER METHODS ============
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Ready':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;
      case 'Processing':
        return Icons.autorenew;
      case 'Ready':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _editCustomer() {
    _showEditCustomerDialog(customerData);
  }

  void _createNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MainOrderScreen(chosenCustomer: customerData),
      ),
    );
  }

  void _viewOrder(int orderId) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
    );

    if (updated == true && mounted) {
      _loadCustomerData();
    }
  }

  Future<void> _showEditCustomerDialog(Map<String, dynamic> customer) async {
    final nameController = TextEditingController(text: customer['name']);
    final phoneController = TextEditingController(
      text: customer['phone'] ?? '',
    );
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental closing
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 600, // Fixed width for desktop
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============ HEADER WITH GRADIENT ============
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Update information for ${customer['name']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // ============ FORM BODY ============
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer ID Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Customer ID: ${customer['id']}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Customer Name Field
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter customer full name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Phone Number Field
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ============ FOOTER ACTIONS ============
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Save Button
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final Map<String, dynamic> data = {
                              'name': nameController.text,
                              'phone': phoneController.text,
                            };

                            final isEdited =
                                await CustomerService.updateCustomer(
                                  customerData['id'],
                                  data,
                                );

                            Navigator.pop(context);
                            isEdited == true
                                ? ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Customer ${nameController.text} updated successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : null;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
