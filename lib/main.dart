import 'package:donnih/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'presentation/pages/order_status.dart';
import 'presentation/pages/menu_detail.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/loadingscreen.dart';
import 'presentation/pages/homepage.dart';
import 'presentation/pages/favourites_page.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/admin_order_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  usePathUrlStrategy();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/order-status': (context) => const OrderStatusPage(),
        '/menu-detail': (context) => const MenuDetailPage(),
        '/cart': (context) => const CartPage(),
        '/favourites': (context) => const FavouritesPage(),
        '/profile': (context) => const ProfilePage(),
        '/admin-order-status': (context) => const AdminOrderStatusPage(),
      },
    );
  }
}

class AllPage extends StatelessWidget {
  const AllPage({super.key});

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

            //SignUpPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Buka Sign Up Page'),
            ),
            const SizedBox(height: 20),

            //LoginPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Buka Login Page'),
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

            //FavouritesPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(initialIndex: 1),
                  ),
                );
              },
              child: const Text('Buka Favourites Page'),
            ),
            const SizedBox(height: 20),

            //ProfilePage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(initialIndex: 3),
                  ),
                );
              },
              child: const Text('Buka Profile'),
            ),
            const SizedBox(height: 20),

            // LoadingScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoadingScreen(),
                  ),
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
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('Buka Home Page'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
