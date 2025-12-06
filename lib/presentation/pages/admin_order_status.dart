import 'package:flutter/material.dart';
import '../widgets/admin_page_nav.dart';
import 'admin_order_detail.dart';

class AdminOrderStatusPage extends StatefulWidget {
  const AdminOrderStatusPage({super.key});

  @override
  State<AdminOrderStatusPage> createState() => _AdminOrderStatusPageState();
}

class _AdminOrderStatusPageState extends State<AdminOrderStatusPage> {
  int _currentIndex = 1; // Order is selected by default

  // Sample order data with complete details
  final List<Map<String, dynamic>> orders = [
    {
      'orderNumber': 'Order #005',
      'price': 'Rp213.000',
      'status': 'Order Confirmed',
      'statusLevel': 1,
      'items': [
        {'quantity': 2, 'name': 'Cappuccino', 'price': 'Rp58.000'},
        {'quantity': 1, 'name': 'Peach Tea', 'price': 'Rp18.000'},
        {'quantity': 1, 'name': 'Americano', 'price': 'Rp23.000'},
        {'quantity': 2, 'name': 'Strawberry Pancake', 'price': 'Rp72.000'},
        {'quantity': 1, 'name': 'Japanese Curry', 'price': 'Rp42.000'},
      ],
      'paymentMethod': 'Cash',
    },
    {
      'orderNumber': 'Order #004',
      'price': 'Rp84.000',
      'status': 'Order Processed',
      'statusLevel': 2,
      'items': [
        {'quantity': 1, 'name': 'Americano', 'price': 'Rp18.000'},
        {'quantity': 2, 'name': 'Peach Tea', 'price': 'Rp36.000'},
        {'quantity': 1, 'name': 'Cafe Latte', 'price': 'Rp30.000'},
      ],
      'paymentMethod': 'Cash',
    },
    {
      'orderNumber': 'Order #003',
      'price': 'Rp184.000',
      'status': 'Order Completed',
      'statusLevel': 3,
      'items': [
        {'quantity': 3, 'name': 'Cappuccino', 'price': 'Rp87.000'},
        {'quantity': 2, 'name': 'Japanese Curry', 'price': 'Rp84.000'},
        {'quantity': 1, 'name': 'Apple Tea', 'price': 'Rp13.000'},
      ],
      'paymentMethod': 'E-Wallet',
    },
    {
      'orderNumber': 'Order #002',
      'price': 'Rp96.000',
      'status': 'Order Completed',
      'statusLevel': 3,
      'items': [
        {'quantity': 2, 'name': 'Strawberry Pancake', 'price': 'Rp72.000'},
        {'quantity': 1, 'name': 'Espresso', 'price': 'Rp9.000'},
        {'quantity': 1, 'name': 'Peach Tea', 'price': 'Rp15.000'},
      ],
      'paymentMethod': 'Cash',
    },
    {
      'orderNumber': 'Order #001',
      'price': 'Rp20.000',
      'status': 'Order Completed',
      'statusLevel': 3,
      'items': [
        {'quantity': 1, 'name': 'Espresso', 'price': 'Rp9.000'},
        {'quantity': 1, 'name': 'Apple Tea', 'price': 'Rp11.000'},
      ],
      'paymentMethod': 'Cash',
    },
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation logic
    switch (index) {
      case 0: // Home
        // Navigate to admin home page
        // Navigator.pushReplacementNamed(context, '/admin-home');
        break;
      case 1: // Order
        // Already on order status page
        break;
      case 2: // Profile
        // Navigate to admin profile page
        // Navigator.pushReplacementNamed(context, '/admin-profile');
        break;
    }
  }

  void _navigateToDetail(int orderIndex) {
    final order = orders[orderIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminOrderDetailPage(
          orderNumber: order['orderNumber'],
          totalPrice: order['price'],
          items: List<Map<String, dynamic>>.from(order['items']),
          paymentMethod: order['paymentMethod'],
          initialStatus: order['statusLevel'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 35,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Order List
                      ...orders.asMap().entries.map((entry) {
                        final index = entry.key;
                        final order = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildOrderCard(
                            orderNumber: order['orderNumber'],
                            price: order['price'],
                            status: order['status'],
                            onTap: () => _navigateToDetail(index),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Navigation
            AdminPageNav(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderNumber,
    required String price,
    required String status,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFCB8A58),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Number and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Plus Jakarta Sans',
                          height: 1.5,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontFamily: 'Plus Jakarta Sans',
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Status
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF846046),
                      fontFamily: 'Plus Jakarta Sans',
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF422110),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
