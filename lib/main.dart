import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// --- IMPORT HALAMAN ---
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/order_status.dart';
import 'presentation/pages/menu_detail.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/loadingscreen.dart';
import 'presentation/pages/homepage.dart';
import 'presentation/pages/favourites_page.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/login_page.dart';

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
      title: 'Aplikasi Don.Nih',

      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
        
      initialRoute: '/debug', 
      routes: {
        '/': (context) => const LoadingScreen(),
        '/debug': (context) => const AllPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(initialIndex: 0),
        '/order-status': (context) => const OrderStatusPage(),
        '/menu-detail': (context) => const MenuDetailPage(),
        '/cart': (context) => const HomePage(initialIndex: 2),
        '/favourites': (context) => const HomePage(initialIndex: 1),
        '/profile': (context) => const HomePage(initialIndex: 3),
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
            ],
          ),
        ),
      ),
    );
  }
}