import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // ============ SAMPLE METRICS DATA ============
  final Map<String, dynamic> _metricsData = {
    'revenue': {'total': 45890.50, 'growth': 12.5, 'previous': 40800.00},
    'orders': {'total': 342, 'growth': 8.3, 'previous': 316},
    'customers': {'total': 189, 'new': 24, 'growth': 14.7},
    'average_order': {'value': 134.20, 'growth': 3.8, 'previous': 129.30},
  };

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'ORD-2024-0042',
      'customer': 'Abebe Kebede',
      'amount': 450.00,
      'status': 'Completed',
      'date': '2024-03-15',
    },
    {
      'id': 'ORD-2024-0041',
      'customer': 'Tigist Haile',
      'amount': 320.00,
      'status': 'Processing',
      'date': '2024-03-15',
    },
    {
      'id': 'ORD-2024-0040',
      'customer': 'Mekdes Alemu',
      'amount': 680.00,
      'status': 'Completed',
      'date': '2024-03-14',
    },
    {
      'id': 'ORD-2024-0039',
      'customer': 'Dawit Mengistu',
      'amount': 210.00,
      'status': 'Pending',
      'date': '2024-03-14',
    },
    {
      'id': 'ORD-2024-0038',
      'customer': 'Sara Tekle',
      'amount': 890.00,
      'status': 'Completed',
      'date': '2024-03-13',
    },
  ];

  final List<Map<String, dynamic>> _topItems = [
    {'name': 'T-Shirt', 'quantity': 145, 'revenue': 725.00},
    {'name': 'Pants', 'quantity': 98, 'revenue': 686.00},
    {'name': 'Dress Shirt', 'quantity': 76, 'revenue': 456.00},
    {'name': 'Jacket', 'quantity': 45, 'revenue': 540.00},
    {'name': 'Bed Sheet', 'quantity': 38, 'revenue': 380.00},
  ];

  final List<Map<String, dynamic>> _dailyRevenue = [
    {'day': 'Mon', 'revenue': 1250},
    {'day': 'Tue', 'revenue': 1480},
    {'day': 'Wed', 'revenue': 1620},
    {'day': 'Thu', 'revenue': 1890},
    {'day': 'Fri', 'revenue': 2100},
    {'day': 'Sat', 'revenue': 1950},
    {'day': 'Sun', 'revenue': 1100},
  ];

  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'This Month';
  final List<String> _filterOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
    'This Year',
    'Custom Range',
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFF2196F3),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _refreshMetrics,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: 'Refresh',
            ),
          ),

          // Export Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _exportMetrics,
              icon: const Icon(Icons.download, color: Colors.grey),
              tooltip: 'Export',
            ),
          ),

          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============ FILTER SECTION ============
                      _buildFilterSection(isMobile, isTablet, isDesktop),

                      const SizedBox(height: 24),

                      // ============ METRICS CARDS ============
                      _buildMetricsGrid(isMobile, isTablet, isDesktop),

                      const SizedBox(height: 24),

                      // ============ CHARTS & TABLES SECTION ============
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildRevenueChart()),
                            const SizedBox(width: 20),
                            Expanded(flex: 1, child: _buildTopItems()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildRevenueChart(),
                            const SizedBox(height: 20),
                            _buildTopItems(),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // ============ RECENT ORDERS ============
                      _buildRecentOrders(isMobile),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ============ FILTER SECTION ============
  Widget _buildFilterSection(bool isMobile, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_outlined,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Filter Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                _getDateRangeText(),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isMobile)
            Column(
              children: [
                _buildFilterDropdown(),
                const SizedBox(height: 12),
                _buildMonthPicker(),
              ],
            )
          else if (isTablet)
            Row(
              children: [
                Expanded(child: _buildFilterDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildMonthPicker()),
              ],
            )
          else
            Row(
              children: [
                Container(width: 200, child: _buildFilterDropdown()),
                const SizedBox(width: 12),
                Container(width: 200, child: _buildMonthPicker()),
                const Spacer(),
                _buildComparisonToggle(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: _filterOptions.map((String option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Actual', true),
          _buildToggleOption('vs Previous', false),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ============ METRICS GRID ============
  Widget _buildMetricsGrid(bool isMobile, bool isTablet, bool isDesktop) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildMetricCard(
          icon: Icons.attach_money,
          title: 'Revenue',
          value: 'ETB ${_metricsData['revenue']['total'].toStringAsFixed(2)}',
          change: _metricsData['revenue']['growth'],
          color: Colors.green,
        ),
        _buildMetricCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Orders',
          value: _metricsData['orders']['total'].toString(),
          change: _metricsData['orders']['growth'],
          color: Colors.blue,
        ),
        _buildMetricCard(
          icon: Icons.people_outline,
          title: 'Customers',
          value: _metricsData['customers']['total'].toString(),
          subtitle: '+${_metricsData['customers']['new']} new',
          color: Colors.purple,
        ),
        _buildMetricCard(
          icon: Icons.trending_up,
          title: 'Avg. Order',
          value:
              'ETB ${_metricsData['average_order']['value'].toStringAsFixed(2)}',
          change: _metricsData['average_order']['growth'],
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    double? change,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============ REVENUE CHART ============
  Widget _buildRevenueChart() {
    final maxRevenue = _dailyRevenue
        .map((e) => e['revenue'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
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
              const Text(
                'Revenue Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+12.5% vs last week',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Simple bar chart representation
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _dailyRevenue.map((item) {
                final revenue = item['revenue'] as int;
                final height = (revenue / maxRevenue) * 140;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['day'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChartLegend('Total', 'ETB 11,390', Colors.blue),
              _buildChartLegend('Average', 'ETB 1,627', Colors.teal),
              _buildChartLegend('Best Day', 'Fri - ETB 2,100', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============ TOP ITEMS ============
  Widget _buildTopItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_laundry_service,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Top Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topItems.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final item = _topItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getItemColor(index).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getItemColor(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${item['quantity']} units',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'ETB ${item['revenue'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009688),
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

  Color _getItemColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ============ RECENT ORDERS ============
  Widget _buildRecentOrders(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrders.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final order = _recentOrders[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(order['customer']),
                  subtitle: Text(order['id']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ETB ${order['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(order['status']),
                    ],
                  ),
                );
              },
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    _buildTableHeader('Order ID'),
                    _buildTableHeader('Customer'),
                    _buildTableHeader('Date'),
                    _buildTableHeader('Amount'),
                    _buildTableHeader('Status'),
                  ],
                ),
                ..._recentOrders.map((order) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(order['id']),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(order['customer']),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(order['date']),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'ETB ${order['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildStatusChip(order['status']),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Processing':
        color = Colors.blue;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ============ HELPER METHODS ============
  String _getDateRangeText() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        return DateFormat('MMM dd, yyyy').format(now);
      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
      case 'This Month':
        return DateFormat('MMMM yyyy').format(now);
      default:
        return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2196F3)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _refreshMetrics() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard refreshed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _exportMetrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting metrics...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
