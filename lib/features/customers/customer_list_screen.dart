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

  Future<void> _fetchCustomer() async {
    final db = await AppDatabase.database;

    final result = await db.query('customers', orderBy: 'id DESC');
    setState(() {
      customers = result;
      _isLoading = false;
    });
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
                    decoration: InputDecoration(
                      hint: Text('eg. Abebe or 091234... '),
                      suffixIcon: Icon(Icons.search),
                    ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(customer['phone'] ?? '_'),
                  );
                },
              ),
            ),
          );
  }
}
