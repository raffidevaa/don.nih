import 'package:flutter/material.dart';

// 1. Model data untuk setiap pesanan
class Order {
  final String id;
  final String price;
  final String status;

  Order({required this.id, required this.price, required this.status});
}

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  // 2. Data dummy yang sesuai dengan desain
  final List<Order> _orders = [
    Order(id: '#005', price: '213.000', status: 'Order Confirmed'),
    Order(id: '#004', price: '84.000', status: 'Order Processed'),
    Order(id: '#003', price: '184.000', status: 'Order Completed'),
    Order(id: '#002', price: '96.000', status: 'Order Completed'),
    Order(id: '#001', price: '20.000', status: 'Order Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 3. AppBar yang disesuaikan
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Order Status",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF6F4E37), // Warna coklat tua
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          // 4. Memanggil widget kartu kustom untuk setiap item
          return OrderStatusCard(order: order);
        },
      ),
    );
  }
}

// 5. Widget kartu kustom untuk menampilkan detail pesanan
class OrderStatusCard extends StatelessWidget {
  final Order order;

  const OrderStatusCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFD2B48C), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp${order.price}',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  order.status,
                  style: const TextStyle(
                    color: Color(0xFFC89B64),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
