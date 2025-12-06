import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final String orderNumber;
  final String totalPrice;
  final List<Map<String, dynamic>> items;
  final String paymentMethod;
  final int initialStatus; // 0: Waiting, 1: Confirmed, 2: Processed, 3: Completed

  const AdminOrderDetailPage({
    super.key,
    required this.orderNumber,
    required this.totalPrice,
    required this.items,
    this.paymentMethod = 'Cash',
    this.initialStatus = 0,
  });

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late int _currentStatus;
  late List<Map<String, dynamic>> _statusHistory;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _initializeStatusHistory();
  }

  void _initializeStatusHistory() {
    final now = DateTime.now();
    _statusHistory = [
      {
        'title': 'Waiting Confirmation',
        'timestamp': now,
        'isCompleted': _currentStatus >= 0,
      },
      {
        'title': 'Order Confirmed',
        'timestamp': _currentStatus >= 1
            ? now.add(const Duration(minutes: 1))
            : now.add(const Duration(minutes: 1)),
        'isCompleted': _currentStatus >= 1,
      },
      {
        'title': 'Order Processed',
        'timestamp': _currentStatus >= 2
            ? now.add(const Duration(minutes: 3))
            : now.add(const Duration(minutes: 3)),
        'isCompleted': _currentStatus >= 2,
      },
      {
        'title': 'Order Completed',
        'timestamp': _currentStatus >= 3
            ? now.add(const Duration(minutes: 38))
            : now.add(const Duration(minutes: 38)),
        'isCompleted': _currentStatus >= 3,
      },
    ];
  }

  String _getButtonText() {
    switch (_currentStatus) {
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

  void _updateOrderStatus() {
    if (_currentStatus < 3) {
      setState(() {
        _currentStatus++;
        _statusHistory[_currentStatus]['isCompleted'] = true;
        _statusHistory[_currentStatus]['timestamp'] = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => Navigator.pop(context),
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
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Order Items List
                ...widget.items.map((item) => _buildOrderItem(
                      quantity: item['quantity'],
                      name: item['name'],
                      price: item['price'],
                    )),
                const SizedBox(height: 15),

                // Payment Method and Total
                _buildInfoRow('Payment Method', widget.paymentMethod),
                _buildInfoRow('Total', widget.totalPrice),
                const SizedBox(height: 20),

                // Action Button
                if (_currentStatus < 3)
                  GestureDetector(
                    onTap: _updateOrderStatus,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF422110),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Text(
                        _getButtonText(),
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
                    children: _statusHistory
                        .asMap()
                        .entries
                        .map((entry) => _buildStatusItem(
                              title: entry.value['title'],
                              timestamp: entry.value['timestamp'],
                              isCompleted: entry.value['isCompleted'],
                              isLast: entry.key == _statusHistory.length - 1,
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
  }

  Widget _buildOrderItem({
    required int quantity,
    required String name,
    required String price,
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
                price,
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
