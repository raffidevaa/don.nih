import 'package:flutter/material.dart';
import 'order_status.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp creates the Navigator
    return const MaterialApp(
      home: HomePage(), // Set home to our new HomePage widget
    );
  }
}

// This is the new HomePage widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This context is now under MaterialApp, so it has a Navigator.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aplikasi Don.Nih"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // This will work now!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderStatusPage()),
            );
          },
          child: const Text('Lihat Status Pesanan'),
        ),
      ),
    );
  }
}
