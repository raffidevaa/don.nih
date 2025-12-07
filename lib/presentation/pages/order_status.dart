import 'package:flutter/material.dart';
import 'order_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/order_datasource.dart';
import '../../domain/entities/order_entity.dart';

// Model data untuk setiap pesanan
class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

Future<List<OrderEntity>> _fetchOrderHistory() async {
  final authUser = Supabase.instance.client.auth.currentUser;
  final orderHistory = OrderDatasource(
    Supabase.instance.client,
  ).getOrdersByUserId(authUser!.id);
  return orderHistory;
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Order Status",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fetchOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderStatusCard(order: order);
            },
          );
        },
      ),
    );
  }
}

// Widget kartu kustom untuk menampilkan detail pesanan
class OrderStatusCard extends StatelessWidget {
  final OrderEntity order;

  const OrderStatusCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 2. Menambahkan GestureDetector untuk navigasi
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderDetailPage()),
        );
      },
      child: Padding(
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
                    'Rp${order.netIncome}',
                    // 3. Warna diperbaiki
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.orderStatus,
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
                  // 3. Warna diperbaiki
                  color: Color(0xFF6F4E37),
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
      ),
    );
  }
}
