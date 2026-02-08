import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //items list
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  //fetching all items
  Future<void> _fetchItems() async {
    try {
      final db = await AppDatabase.database;
      final items = await db.query('items', orderBy: 'id DESC');
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final name = _itemNameController.text.trim();
      final price = double.parse(_itemPriceController.text.trim());

      final db = await AppDatabase.database;
      await db.insert('items', {'name': name, 'price': price});

      _itemNameController.clear();
      _itemPriceController.clear();
      _fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding item: $e")));
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int id) async {
    try {
      final db = await AppDatabase.database;
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
      _fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting item: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body: _isLoading
          ? CircularProgressIndicator()
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter item name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _itemPriceController,
                      decoration: InputDecoration(labelText: "Item Price"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter item price";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addItem,
                      child: const Text("Add Item"),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'List of Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (_, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price: \$${item['price']}"),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _confirmDelete(item['id']),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
