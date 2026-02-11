import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> customers = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  //search controler
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchCustomer({String query = ''}) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'customers',
      orderBy: 'id DESC',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    setState(() {
      customers = result;
      _isLoading = false;
    });
  }

  void _deleteCustomer(int id) async {
    final db = await AppDatabase.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
    _fetchCustomer();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confrim Delete"),
        content: const Text("Are you sure you want to delete this customer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomer(id);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

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

  @override
  void initState() {
    super.initState();
    _fetchCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text('Customer List'),
              backgroundColor: Colors.blueGrey.shade100,
              actions: [
                Container(
                  width: 300,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hint: Text('eg. Abebe or 091234... '),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _fetchCustomer(query: value);
                    },
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (_, index) {
                  final customer = customers[index];

                  return ListTile(
                    title: Text(
                      customer['name'],
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(customer['phone'] ?? '_'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _confirmDelete(customer['id']),
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
  }
}
