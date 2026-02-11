import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/service/customer_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  //search controler
  final TextEditingController _searchController = TextEditingController();

  // Future<void> _fetchCustomer({String query = ''}) async {
  //   final db = await AppDatabase.database;

  //   final result = await db.query(
  //     'customers',
  //     orderBy: 'id DESC',
  //     where: 'name LIKE ?',
  //     whereArgs: ['%$query%'],
  //   );
  // }

  // void _confirmDelete(int id) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Confrim Delete"),
  //       content: const Text("Are you sure you want to delete this customer?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _deleteCustomer(id);
  //           },
  //           child: Text("Delete"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _openEditDialogueBox(int id) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    final customerData = result.first;
    setState(() {
      _nameController.text = customerData['name']?.toString() ?? '';
      _phoneController.text = customerData['phone']?.toString() ?? '';
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Customer'),
        content: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Customer Phone'),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchCustomer() async {
    final result = await CustomerService.fetchCustomer();
    setState(() {
      customers = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomer();
    _searchController.addListener(() {
      _filterCustomers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading customers...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Row(
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
                      Icons.people_outline,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Customer List',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${customers.length} ${customers.length == 1 ? 'customer' : 'customers'}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                // Add Customer Button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.teal.withOpacity(0.1),
                  ),
                  child: IconButton(
                    onPressed: _showAddCustomerDialog,
                    icon: const Icon(Icons.person_add, color: Colors.teal),
                    tooltip: 'Add Customer',
                    iconSize: 24,
                  ),
                ),
                const SizedBox(width: 8),

                // Search Field
                Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
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
                    onChanged: (value) {
                      _filterCustomers(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        size: 20,
                                        color: Color(0xFF2196F3),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Total: ${customers.length}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 20,
                                        color: Colors.teal,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'With Phone: ${_customersWithPhone()}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Export/Refresh Buttons
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: _refreshCustomers,
                                    icon: const Icon(Icons.refresh),
                                    tooltip: 'Refresh',
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: _exportCustomers,
                                    icon: const Icon(Icons.download),
                                    tooltip: 'Export',
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Customers Grid/List
                        Expanded(
                          child: _filteredCustomers.isEmpty
                              ? _buildEmptyState()
                              : GridView.builder(
                                  key: const PageStorageKey<String>(
                                    'customers_grid',
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.8,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: _filteredCustomers.length,
                                  itemBuilder: (_, index) {
                                    final customer = _filteredCustomers[index];
                                    return _buildCustomerCard(customer);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  // ============ CUSTOMER CARD WIDGET ============
  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final hasPhone =
        customer['phone'] != null && customer['phone'].toString().isNotEmpty;
    final phoneNumber = hasPhone ? customer['phone'].toString() : 'No phone';
    final initial = customer['name'].toString().substring(0, 1).toUpperCase();
    final randomColor =
        Colors.primaries[customer['id'] % Colors.primaries.length];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _viewCustomerDetails(customer),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Header with Avatar
                Row(
                  children: [
                    // Avatar with gradient background
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [randomColor.withOpacity(0.7), randomColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: randomColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Customer Name and ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ID: ${customer['id']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Phone Number with Icon
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPhone ? Icons.phone : Icons.phone_missed,
                        size: 14,
                        color: hasPhone ? Colors.teal : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasPhone
                                ? Colors.teal.shade700
                                : Colors.grey.shade600,
                            fontWeight: hasPhone
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () => _editCustomer(customer),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF2196F3),
                        ),
                        tooltip: 'Edit Customer',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () => _confirmDelete(customer['id']),
                        icon: const Icon(
                          Icons.delete_outlined,
                          size: 18,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete Customer',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // View Details Arrow
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ EMPTY STATE ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isNotEmpty
                ? 'No customers found'
                : 'No customers yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search term'
                : 'Add your first customer to get started',
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
            )
          else
            ElevatedButton.icon(
              onPressed: _showAddCustomerDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
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

  // ============ ADD CUSTOMER DIALOG ============
  Future<void> _showAddCustomerDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add New Customer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Customer Name',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  CustomerService.addCustomer(
                    nameController.text,
                    phone: phoneController.text,
                  );
                  Navigator.pop(context);
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer added successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _refreshCustomers();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Customer'),
            ),
          ],
        );
      },
    );
  }

  // ============ DELETE CONFIRMATION DIALOG ============
  Future<void> _confirmDelete(int id, {String customerName = 'Yared'}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "$customerName"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone. All order history for this customer will be affected.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      CustomerService.deleteCustomer(id);
      _refreshCustomers();
    }
  }

  // ============ HELPER METHODS ============
  int _customersWithPhone() {
    return customers.where((c) {
      final phone = c['phone'];
      return phone != null && phone.toString().isNotEmpty;
    }).length;
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = List.from(customers);
      } else {
        final searchLower = query.toLowerCase();
        _filteredCustomers = customers.where((customer) {
          final name = customer['name'].toString().toLowerCase();
          final phone = customer['phone']?.toString().toLowerCase() ?? '';
          return name.contains(searchLower) || phone.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterCustomers('');
  }

  void _refreshCustomers() async {
    final result = await CustomerService.fetchCustomer(
      query: _searchController.text,
    );
    setState(() {
      customers = result;
      _filterCustomers(_searchController.text);
    });
  }

  void _exportCustomers() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewCustomerDetails(Map<String, dynamic> customer) {
    // TODO: Navigate to customer details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${customer['name']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editCustomer(Map<String, dynamic> customer) {
    // TODO: Implement edit customer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${customer['name']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
