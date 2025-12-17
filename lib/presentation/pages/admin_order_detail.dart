import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/admin_order_datasource.dart';
import '../../data/datasources/order_detail_datasource.dart';
import '../../domain/entities/order_entity.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late Future<Map<String, dynamic>> _orderDataFuture;
  bool _isUpdating = false;
  final AdminOrderDatasource _orderDatasource = AdminOrderDatasource(Supabase.instance.client);
  final OrderDetailDatasource _orderDetailDatasource = OrderDetailDatasource(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  void _loadOrderData() {
    _orderDataFuture = _fetchOrderData();
  }

  Future<Map<String, dynamic>> _fetchOrderData() async {
    final order = await _orderDatasource.getOrderById(widget.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }
    
    final orderDetails = await _orderDetailDatasource.getOrderDetailByOrderId(widget.orderId);
    
    return {
      'order': order,
      'details': orderDetails,
    };
  }

  int _getStatusLevel(String status) {
    switch (status) {
      case 'WAITING':
        return 0;
      case 'CONFIRMED':
        return 1;
      case 'PROCESSED':
        return 2;
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

  List<Map<String, dynamic>> _initializeStatusHistory(int currentStatus, DateTime createdAt) {
    return [
      {
        'title': 'Waiting Confirmation',
        'timestamp': createdAt,
        'isCompleted': currentStatus >= 0,
      },
      {
        'title': 'Order Confirmed',
        'timestamp': createdAt.add(const Duration(minutes: 1)),
        'isCompleted': currentStatus >= 1,
      },
      {
        'title': 'Order Processed',
        'timestamp': createdAt.add(const Duration(minutes: 3)),
        'isCompleted': currentStatus >= 2,
      },
      {
        'title': 'Order Completed',
        'timestamp': createdAt.add(const Duration(minutes: 38)),
        'isCompleted': currentStatus >= 3,
      },
    ];
  }

  String _getButtonText(int currentStatus) {
    switch (currentStatus) {
      case 0:
        return 'Confirm Order';
      case 1:
        return 'Process Order';
      case 2:
        return 'Complete Order';
      default:
        return 'Order Completed';
    }
  }

  String _getNextStatus(int currentStatus) {
    switch (currentStatus) {
      case 0:
        return 'CONFIRMED';
      case 1:
        return 'PROCESSED';
      case 2:
        return 'COMPLETED';
      default:
        return 'COMPLETED';
    }
  }

  Future<void> _updateOrderStatus(int currentStatus) async {
    if (currentStatus >= 3 || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Update status di database
      final newStatus = _getNextStatus(currentStatus);
      await _orderDatasource.updateOrderStatus(widget.orderId, newStatus);

      // Reload data
      setState(() {
        _loadOrderData();
        _isUpdating = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _orderDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final OrderEntity order = data['order'];
        final List<Map<String, dynamic>> orderDetails = data['details'];
        final int currentStatus = _getStatusLevel(order.orderStatus);
        final statusHistory = _initializeStatusHistory(currentStatus, order.createdAt);
        
        // Calculate total and extract menu names
        double total = 0;
        final List<Map<String, dynamic>> processedDetails = [];
        
        for (var detail in orderDetails) {
          final price = (detail['price'] as num?)?.toDouble() ?? 0;
          final quantity = (detail['quantity'] as int?) ?? 0;
          total += price * quantity;
          
          // Extract menu name from nested structure
          String menuName = 'Unknown Item';
          try {
            final menuToppings = detail['menu_toppings'] as Map<String, dynamic>?;
            if (menuToppings != null) {
              final menus = menuToppings['menus'] as Map<String, dynamic>?;
              if (menus != null) {
                menuName = menus['name'] as String? ?? 'Unknown Item';
              }
            }
          } catch (e) {
            // Keep default 'Unknown Item'
          }
          
          processedDetails.add({
            'quantity': quantity,
            'name': menuName,
            'price': price,
          });
        }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, true), // Return true to indicate update
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF422110),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Order Items List
                ...processedDetails.map((detail) => _buildOrderItem(
                      quantity: detail['quantity'],
                      name: detail['name'],
                      price: detail['price'],
                    )),
                const SizedBox(height: 15),

                // Payment Method and Total
                _buildInfoRow('Payment Method', 'Cash'),
                _buildInfoRow('Total', 'Rp ${NumberFormat('#,###', 'id_ID').format(total)}'),
                const SizedBox(height: 20),

                // Action Button
                if (currentStatus < 3)
                  GestureDetector(
                    onTap: _isUpdating ? null : () => _updateOrderStatus(currentStatus),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _isUpdating 
                            ? const Color(0xFF422110).withOpacity(0.5)
                            : const Color(0xFF422110),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: _isUpdating
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              _getButtonText(currentStatus),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Status Tracker
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: statusHistory
                        .asMap()
                        .entries
                        .map((entry) => _buildStatusItem(
                              title: entry.value['title'],
                              timestamp: entry.value['timestamp'],
                              isCompleted: entry.value['isCompleted'],
                              isLast: entry.key == statusHistory.length - 1,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildOrderItem({
    required int quantity,
    required String name,
    required double price,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(price)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: const Color(0xFF422110),
          margin: const EdgeInsets.only(top: 1, bottom: 15),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required DateTime timestamp,
    required bool isCompleted,
    required bool isLast,
  }) {
    final dateFormat = DateFormat('MMMM d, yyyy, h:mm a');
    final timeString = dateFormat.format(timestamp);
    final estimatedPrefix = isCompleted ? '' : 'estimated ';

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and line
          Column(
            children: [
              // Icon
              Container(
                width: 24,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF846046)
                      : const Color(0xFFCBCBD4),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              // Connecting line
              if (!isLast)
                Container(
                  width: 4,
                  height: 60,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF846046)
                        : const Color(0xFFCBCBD4),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Status info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                      color: isCompleted
                          ? const Color(0xFF846046)
                          : const Color(0xFFCBCBD4),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$estimatedPrefix$timeString',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
