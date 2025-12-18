import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// --- IMPORT HALAMAN ---
import 'presentation/pages/order_status.dart';
import 'presentation/pages/order_detail.dart';
import 'presentation/pages/menu_detail.dart';
import 'presentation/pages/loadingscreen.dart';
import 'presentation/pages/homepage.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/admin_order_status.dart';
import 'presentation/pages/admin_order_detail.dart';
import 'presentation/pages/profile_page.dart';

// ========== ADMIN PAGES ==========
import 'presentation/pages/admin_homepage.dart';

Future<void> main() async {
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
      title: 'Aplikasi Don.Nih',

      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),

      initialRoute: '/login',

      routes: {
        // ===== SYSTEM =====
        '/': (context) => const LoadingScreen(),

        // ===== AUTH =====
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // ===== USER =====
        '/home': (context) => const HomePage(initialIndex: 0),
        '/order': (context) => const OrderStatusPage(),
        '/menu-detail': (context) => const MenuDetailPage(),
        '/cart': (context) => const HomePage(initialIndex: 2),
        '/favourites': (context) => const HomePage(initialIndex: 1),
        '/order-status': (context) => const OrderStatusPage(),
        '/order-detail': (context) {
          final orderId = ModalRoute.of(context)?.settings.arguments as int?;
          if (orderId == null) {
            return const Scaffold(
              body: Center(child: Text('Order ID tidak ditemukan')),
            );
          }
          return OrderDetailPage(orderId: orderId);
        },
        '/profile': (context) => const ProfilePage(),
        '/admin/orders': (context) => const AdminOrderStatusPage(),
        '/admin/order-detail': (context) {
          final orderId = ModalRoute.of(context)?.settings.arguments as int?;
          if (orderId == null) {
            return const Scaffold(
              body: Center(child: Text('Order ID tidak ditemukan')),
            );
          }
          return AdminOrderDetailPage(orderId: orderId);
        },
        '/admin/home': (context) => const AdminHomePage(),
      },
    );
  }
}

class AllPage extends StatelessWidget {
  const AllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Debugging Dev")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Klik tombol untuk tes URL berubah:"),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Ke Login (/login)')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/home'), child: const Text('Ke Home (/home)')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/favourites'), child: const Text('Ke Favorites (/favourites)')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/profile'), child: const Text('Ke Profile (/profile)')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/cart'), child: const Text('Ke Cart (/cart)')),
              const SizedBox(height: 20),
              const Divider(),
              const Text("Admin Pages:"),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/admin/orders'), child: const Text('Admin Orders (/admin/orders)')),
            ],
          ),
        ),
      ),
    );
  }
}
