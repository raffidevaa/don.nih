import 'package:flutter/material.dart';
import '../../data/models/menu_model.dart';
import 'admin_add_menu_page.dart';

class AdminMenuDetailPage extends StatelessWidget {
  final MenuModel menu;
  const AdminMenuDetailPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminAddMenuPage(menu: menu),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: const Color(0xFFF2F2F2),
            child: const Icon(
              Icons.fastfood,
              size: 80,
              color: Colors.brown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp${menu.price.toInt()}',
                  style: const TextStyle(fontSize: 18),
                ),
                if (menu.topping != null) ...[
                  const SizedBox(height: 12),
                  Text('Topping ID: ${menu.topping}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
