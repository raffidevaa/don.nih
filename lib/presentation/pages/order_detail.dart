import 'package:flutter/material.dart';
import '../../data/datasources/order_detail_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/order_datasource.dart';

// Model untuk menggabungkan data yang diambil untuk UI
class _OrderDetailViewData {
  final List<Map<String, dynamic>> items;
  final String status;

  _OrderDetailViewData({required this.items, required this.status});
}

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // Menggunakan Future untuk menampung seluruh data yang dibutuhkan view
  late final Future<_OrderDetailViewData> _viewDataFuture;

  @override
  void initState() {
    super.initState();
    _viewDataFuture = _fetchViewData();
  }

  // Mengambil semua data yang diperlukan secara paralel
  Future<_OrderDetailViewData> _fetchViewData() async {
    // Ganti OrderDetailDatasource dan OrderDatasource dengan implementasinya jika berbeda
    final supabase = Supabase.instance.client;

    final results = await Future.wait([
      OrderDetailDatasource(supabase).getOrderDetailByOrderId(widget.orderId),
      OrderDatasource(supabase).getOrderStatusByOrderId(widget.orderId),
    ]);

    // Ekstrak hasil dengan aman
    final items = results[0] as List<Map<String, dynamic>>;
    final status = results[1] as String;

    return _OrderDetailViewData(
      items: items,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      // Gunakan FutureBuilder untuk menangani state loading, error, dan data
      body: FutureBuilder<_OrderDetailViewData>(
        future: _viewDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return const Center(child: Text('Order details not found.'));
          }

          // Jika data berhasil didapat, bangun UI
          final viewData = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              _buildOrderSummaryCard(viewData.items),
              const SizedBox(height: 30),
              _buildStatusTimeline(viewData.status),
            ],
          );
        },
      ),
    );
  }

  // ... Helper widget lainnya (AppBar, dll) ...

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
              color: Color(0xFF6F4E37),
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

  Widget _buildOrderSummaryCard(List<Map<String, dynamic>> orderItems) {
    // Hitung total harga secara dinamis
    final double total = orderItems.fold(0, (sum, item) => sum + (item['price'] as num));

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          ...orderItems.map((item) => _buildOrderItemRow(item)),
          const SizedBox(height: 16),
          _buildSummaryRow('Payment Method', 'Cash'), // Masih statis, bisa diambil dari data order jika ada
          const SizedBox(height: 10),
          _buildSummaryRow('Total', 'Rp${total.toStringAsFixed(0)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    final price = (item['price'] as num).toStringAsFixed(0);
    final quantity = item['quantity'];
    // Akses nama menu dengan aman
    final menuName = (item['menus'] as Map<String, dynamic>?)?['name'] ?? 'Product not found';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 25),
              Text(menuName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text("Rp$price", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black26),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    final style = TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500);
    return Row(children: [Text(title, style: style), const Spacer(), Text(value, style: style)]);
  }

  // --- TIMELINE YANG DIPERBAIKI ---

  Widget _buildStatusTimeline(String currentStatus) {
    const allStatuses = ["WAITING", "CONFIRMED", "PROCESSED", "COMPLETED"];

    int currentIndex = allStatuses.indexOf(currentStatus.toUpperCase());

    return Column(
      children: List.generate(allStatuses.length, (index) {
        return _StatusTimelineItem(
          status: allStatuses[index],
          isCompleted: index <= currentIndex,
          isLastItem: index == allStatuses.length - 1,
        );
      }),
    );
  }
}

// --- WIDGET TIMELINE ITEM YANG DIPERBAIKI ---

class _StatusTimelineItem extends StatelessWidget {
  final String status;
  final bool isCompleted;
  final bool isLastItem;

  const _StatusTimelineItem({
    required this.status,
    required this.isCompleted,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    final statusMap = {
      "WAITING": "Waiting Confirmation",
      "CONFIRMED": "Order Confirmed",
      "PROCESSED": "Order Processed",
      "COMPLETED": "Order Completed",
    };

    final Color activeColor = const Color(0xFFC89B64);
    final Color inactiveColor = Colors.grey.shade400;

    final Color dotColor = isCompleted ? activeColor : inactiveColor;
    final Color lineColor = isCompleted ? activeColor : inactiveColor;
    final Color textColor = isCompleted ? Colors.black : inactiveColor;
    final FontWeight fontWeight = isCompleted ? FontWeight.bold : FontWeight.w500;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            if (!isLastItem)
              Container(
                width: 2,
                height: 50, // Jarak antar item
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusMap[status] ?? status, // Tampilkan status dari map
                style: TextStyle(fontSize: 18, color: textColor, fontWeight: fontWeight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
