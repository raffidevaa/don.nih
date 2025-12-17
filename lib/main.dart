import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// ========== USER PAGES ==========
import 'presentation/pages/loadingscreen.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/homepage.dart';
import 'presentation/pages/order_status.dart';
import 'presentation/pages/menu_detail.dart';

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

        // ===== ADMIN =====
        '/admin-dashboard': (context) => const AdminHomePage(),
      },
    );
  }
}
