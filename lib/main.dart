import 'package:flutter/material.dart';
import 'order_status.dart';
import 'menu_detail.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aplikasi Don.Nih")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol lama
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderStatusPage(),
                  ),
                );
              },
              child: const Text('Lihat Status Pesanan'),
            ),

            const SizedBox(height: 20),

            // 🔥 Tombol baru untuk ke MenuDetailPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuDetailPage(),
                  ),
                );
              },
              child: const Text('Buka Menu Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
