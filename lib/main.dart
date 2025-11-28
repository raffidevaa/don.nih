import 'package:flutter/material.dart';
import 'presentation/pages/order_status.dart';
import 'presentation/pages/menu_detail.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/loadingscreen.dart';
import 'presentation/pages/homepage.dart' as NewHomePage;
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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

            //MenuDetailPage
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

            const SizedBox(height: 20),

            // CartPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: const Text('Buka Cart Page'),
            ),

            const SizedBox(height: 20),

            // LoadingScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoadingScreen()),
                );
              },
              child: const Text('Buka Loading Screen'),
            ),

            const SizedBox(height: 20),

            // New Home Page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewHomePage.HomePage()),
                );
              },
              child: const Text('Buka Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
