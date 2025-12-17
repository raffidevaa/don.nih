import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_page_nav.dart';
import '../../data/datasources/admin_order_datasource.dart';
import '../../domain/entities/order_entity.dart';

class AdminOrderStatusPage extends StatefulWidget {
  const AdminOrderStatusPage({super.key});

  @override
  State<AdminOrderStatusPage> createState() => _AdminOrderStatusPageState();
}

class _AdminOrderStatusPageState extends State<AdminOrderStatusPage> {
  int _currentIndex = 1; // Order is selected by default
  late Future<List<OrderEntity>> _ordersFuture;
  final AdminOrderDatasource _orderDatasource = AdminOrderDatasource(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderDatasource.getAllOrders();
    });
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return 'Waiting Confirmation';
      case 'CONFIRMED':
        return 'Order Confirmed';
      case 'PROCESSED':
        return 'Order Processed';
      case 'COMPLETED':
        return 'Order Completed';
      case 'CANCELLED':
        return 'Order Cancelled';
      default:
        return status;
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

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

  Future<void> _navigateToDetail(int orderId) async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/order-detail',
      arguments: orderId,
    );

    // Reload orders if status was updated
    if (result == true) {
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<OrderEntity>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOrders,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No orders found'),
                    );
                  }

                  final orders = snapshot.data!;

                  return SingleChildScrollView(
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
                              fontFamily: 'Lato',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Order List
                          ...orders.map((order) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildOrderCard(
                                orderNumber: 'Order #${order.id.toString().padLeft(3, '0')}',
                                price: _formatPrice(order.netIncome),
                                status: _getStatusText(order.orderStatus),
                                onTap: () => _navigateToDetail(order.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
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
