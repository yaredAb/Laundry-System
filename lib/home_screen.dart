import 'package:flutter/material.dart';
import 'package:laundry_pos/features/orders/find_order_screen.dart';
import 'package:laundry_pos/features/orders/main_order_screen.dart';
import 'package:laundry_pos/features/orders/orders_list_screen.dart';
import 'package:laundry_pos/screens/items_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final screens = [
    MainOrderScreen(),
    OrdersListScreen(),
    FindOrderScreen(),
    ItemsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: "New Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Laundry Items",
          ),
        ],
      ),
    );
  }
}
