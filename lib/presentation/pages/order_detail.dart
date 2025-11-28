import 'package:flutter/material.dart';

// --- DATA MODELS ---
class OrderItem {
  final int quantity;
  final String name;
  final String price;

  const OrderItem({required this.quantity, required this.name, required this.price});
}

class StatusItem {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const StatusItem({required this.title, required this.subtitle, this.isCompleted = false});
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  // --- DUMMY DATA ---
  final List<OrderItem> orderItems = const [
    OrderItem(quantity: 2, name: 'Cappuccino', price: 'Rp58.000'),
    OrderItem(quantity: 1, name: 'Peach Tea', price: 'Rp18.000'),
    OrderItem(quantity: 1, name: 'Americano', price: 'Rp23.000'),
    OrderItem(quantity: 2, name: 'Strawberry Pancake', price: 'Rp72.000'),
    OrderItem(quantity: 1, name: 'Japanese Curry', price: 'Rp42.000'),
  ];

  final List<StatusItem> statusHistory = const [
    StatusItem(title: 'Waiting Confirmation', subtitle: 'April 3, 2023, 4:22 PM', isCompleted: true),
    StatusItem(title: 'Order Confirmed', subtitle: 'April 3, 2023, 4:23 PM', isCompleted: true),
    StatusItem(title: 'Order Processed', subtitle: 'April 3, 2023, estimated 4:25 PM'),
    StatusItem(title: 'Order Completed', subtitle: 'April 3, 2023, estimated 5:00 PM'),
  ];

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildOrderSummaryCard(),
          const SizedBox(height: 30),
          _buildStatusTimeline(),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: const Text(
        "Order Details",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF6F4E37), // Brown color
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      titleSpacing: 10,
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          ...orderItems.map((item) => _buildOrderItemRow(item)).toList(),
          const SizedBox(height: 16),
          _buildSummaryRow('Payment Method', 'Cash'),
          const SizedBox(height: 10),
          _buildSummaryRow('Total', 'Rp213.000', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: List.generate(statusHistory.length, (index) {
        return _StatusTimelineItem(
          item: statusHistory[index],
          isLastItem: index == statusHistory.length - 1,
        );
      }),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 25),
              Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black26),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
    );
    return Row(
      children: [
        Text(title, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}


// --- CUSTOM TIMELINE WIDGET ---

class _StatusTimelineItem extends StatelessWidget {
  final StatusItem item;
  final bool isLastItem;

  const _StatusTimelineItem({required this.item, this.isLastItem = false});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC89B64);
    final Color inactiveColor = Colors.grey.shade400;
    final Color iconBgColor = item.isCompleted ? activeColor : inactiveColor;
    final Color textColor = item.isCompleted ? activeColor : inactiveColor;
    final FontWeight fontWeight = item.isCompleted ? FontWeight.bold : FontWeight.normal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            if (!isLastItem)
              Container(
                width: 2,
                height: 40, // Space between circles
                color: iconBgColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 2.0), // Align text with icon
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(fontSize: 18, color: textColor, fontWeight: fontWeight),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
