import 'package:flutter/material.dart';
import 'package:laundry_pos/features/customers/customer_list_screen.dart';
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

  final List<Widget> _screens = [
    const MainOrderScreen(),
    const OrdersListScreen(),
    const FindOrderScreen(),
    const ItemsScreen(),
    const CustomerListScreen(),
  ];

  final List<String> _titles = [
    'New Order',
    'Orders',
    'Find Order',
    'Service Items',
    'Customers',
  ];

  final List<IconData> _icons = [
    Icons.add_shopping_cart,
    Icons.list_alt,
    Icons.search,
    Icons.local_laundry_service,
    Icons.people,
  ];

  final List<IconData> _selectedIcons = [
    Icons.add_shopping_cart,
    Icons.list_alt,
    Icons.search,
    Icons.local_laundry_service,
    Icons.people,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // ============ DESKTOP SIDEBAR NAVIGATION ============
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // App Logo/Brand Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2196F3), Color(0xFF009688)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_laundry_service,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Maya Laundry',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Management System',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Navigation Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _screens.length,
                    itemBuilder: (context, index) {
                      final isSelected = _currentIndex == index;
                      return _buildNavItem(
                        index: index,
                        icon: _icons[index],
                        label: _titles[index],
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),

                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
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
                          Icons.account_circle_outlined,
                          color: Colors.teal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin User',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'admin@laundry.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, size: 18),
                          color: Colors.grey.shade700,
                          tooltip: 'Logout',
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ============ MAIN CONTENT AREA ============
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  // Top App Bar
                  Container(
                    height: 80,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Page Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getIconColor(
                                  _currentIndex,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _selectedIcons[_currentIndex],
                                color: _getIconColor(_currentIndex),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _titles[_currentIndex],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Quick Actions
                        Row(
                          children: [
                            _buildQuickAction(
                              icon: Icons.notifications_outlined,
                              label: 'Notifications',
                              onTap: _showNotifications,
                              badge: '3',
                            ),
                            const SizedBox(width: 8),
                            _buildQuickAction(
                              icon: Icons.today_outlined,
                              label: 'Today\'s Stats',
                              onTap: _showTodayStats,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickAction(
                              icon: Icons.help_outline,
                              label: 'Help',
                              onTap: _showHelp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Current Screen
                  Expanded(child: _screens[_currentIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ NAVIGATION ITEM ============
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _getIconColor(index).withOpacity(0.1),
                  _getIconColor(index).withOpacity(0.05),
                ],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon with background when selected
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getIconColor(index).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? _getIconColor(index)
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? _getIconColor(index)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),

                // Active Indicator
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getIconColor(index),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ QUICK ACTION BUTTON ============
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // ============ HELPER METHODS ============
  Color _getIconColor(int index) {
    switch (index) {
      case 0: // New Order
        return const Color(0xFF2196F3); // Blue
      case 1: // Orders
        return const Color(0xFF4CAF50); // Green
      case 2: // Find Order
        return const Color(0xFFFF9800); // Orange
      case 3: // Service Items
        return const Color(0xFF9C27B0); // Purple
      case 4: // Customers
        return const Color(0xFF009688); // Teal
      default:
        return Colors.grey;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // TODO: Implement notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTodayStats() {
    // TODO: Implement stats
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Today\'s statistics coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelp() {
    // TODO: Implement help
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help documentation coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============ ALTERNATIVE: MOBILE BOTTOM NAVIGATION ============
// You can keep this as a fallback for mobile devices
class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MainOrderScreen(),
    OrdersListScreen(),
    FindOrderScreen(),
    ItemsScreen(),
    CustomerListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart_outlined),
            selectedIcon: Icon(Icons.add_shopping_cart),
            label: "New Order",
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: "Orders",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Find",
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_outlined),
            selectedIcon: Icon(Icons.local_laundry_service),
            label: "Items",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: "Customers",
          ),
        ],
      ),
    );
  }
}
