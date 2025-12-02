// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'favourites_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'menu_detail.dart';

import '../../data/datasources/menu_datasource.dart';
import '../../data/models/menu_model.dart';
import '../../data/datasources/storage_datasource.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  String? _selectedCategory;
  String? _fullName;

  late MenuDataSource _menuDataSource;
  late StorageDatasource _storageDataSource;

  List<MenuModel> _menus = [];
  Map<int, String?> _menuImages = {}; // menuId -> URL Storage
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _menuDataSource = MenuDataSource(Supabase.instance.client);
    _storageDataSource = StorageDatasource();
    _fetchUserData();
    _fetchMenus();
  }

  void _fetchUserData() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;

      // print("🔍 [DEBUG] Checking logged-in user...");
      if (authUser == null) {
        // print("⚠️ [DEBUG] No auth user found.");
        setState(() => _fullName = "Guest");
        return;
      }

      // print("🔑 [DEBUG] Auth User ID: ${authUser.id}");
      // print("📧 [DEBUG] Auth User Email: ${authUser.email}");

      final profile = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", authUser.id)
          .maybeSingle();

      // print("📌 [DEBUG] Profile Query Result: $profile");

      if (profile == null) {
        // print("❌ [DEBUG] No matching row found in `users` table for this ID!");
        setState(() => _fullName = "Guest");
        return;
      }

      if (!mounted) return;
      setState(() {
        _fullName = profile["fullname"] ?? "Guest";
      });

      // print("✅ [DEBUG] Fullname loaded: $_fullName");
    } catch (e) {
      // print("🔥 [DEBUG] Error in _fetchUserData: $e");
      setState(() => _fullName = "Guest");
    }
  }

  Future<void> _fetchMenus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final menus = await _menuDataSource.getAllMenu();
      _menus = menus;

      // Ambil URL gambar dari Storage untuk tiap menu
      for (var menu in menus) {
        try {
          final url = await _storageDataSource.getImageUrl(
            id: menu.id.toString(),
            folderName: "menu",
            fileType: "png",
          );
          _menuImages[menu.id] = url;
        } catch (_) {
          _menuImages[menu.id] = null;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getCategoryForMenu(String menuName) {
    final name = menuName.toLowerCase();
    if (name.contains('espresso') ||
        name.contains('americano') ||
        name.contains('latte') ||
        name.contains('cappuccino') ||
        name.contains('mocha') ||
        name.contains('coffee'))
      return 'COFFEE';
    if (name.contains('tea') ||
        name.contains('matcha') ||
        name.contains('chocolate') ||
        name.contains('milk'))
      return 'NON-COFFEE';
    if (name.contains('pancake') ||
        name.contains('cake') ||
        name.contains('waffle') ||
        name.contains('ice cream') ||
        name.contains('pudding'))
      return 'DESSERT';
    if (name.contains('toast') ||
        name.contains('egg') ||
        name.contains('sandwich') ||
        name.contains('croissant'))
      return 'BREAKFAST';
    if (name.contains('curry') ||
        name.contains('rice') ||
        name.contains('pasta') ||
        name.contains('noodle') ||
        name.contains('chicken') ||
        name.contains('beef'))
      return 'MEAL';
    return 'COFFEE';
  }

  List<MenuModel> get filteredMenus {
    final Map<String, MenuModel> uniqueMenus = {};
    for (var menu in _menus) {
      if (!uniqueMenus.containsKey(menu.name)) {
        uniqueMenus[menu.name] = menu;
      }
    }
    if (_selectedCategory == null) return uniqueMenus.values.toList();
    return uniqueMenus.values
        .where((menu) => _getCategoryForMenu(menu.name) == _selectedCategory)
        .toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = (_selectedCategory == category) ? null : category;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOriginalHomeUI();
      case 1:
        return const FavouritesPage();
      case 2:
        return const CartPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildOriginalHomeUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5c3d2e),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOriginalHomeUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_fullName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search menu ...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchMenus,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            CategoryChip(
                              icon: '☕',
                              label: 'COFFEE',
                              isSelected: _selectedCategory == 'COFFEE',
                              onTap: () => _onCategorySelected('COFFEE'),
                            ),
                            CategoryChip(
                              icon: '🥤',
                              label: 'NON-COFFEE',
                              isSelected: _selectedCategory == 'NON-COFFEE',
                              onTap: () => _onCategorySelected('NON-COFFEE'),
                            ),
                            CategoryChip(
                              icon: '🍰',
                              label: 'DESSERT',
                              isSelected: _selectedCategory == 'DESSERT',
                              onTap: () => _onCategorySelected('DESSERT'),
                            ),
                            CategoryChip(
                              icon: '🍳',
                              label: 'BREAKFAST',
                              isSelected: _selectedCategory == 'BREAKFAST',
                              onTap: () => _onCategorySelected('BREAKFAST'),
                            ),
                            CategoryChip(
                              icon: '🍽️',
                              label: 'MEAL',
                              isSelected: _selectedCategory == 'MEAL',
                              onTap: () => _onCategorySelected('MEAL'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = filteredMenus[index];
                            final imageUrl = _menuImages[menu.id];

                            return ProductCard(
                              menuId: menu.id,
                              name: menu.name,
                              price: menu.price.toInt(),
                              imageUrl: imageUrl,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// === COMPONENTS ===

class CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF8B6F47) : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(25),
          color: isSelected ? const Color(0xFFFAF3EE) : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF8B6F47) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final int menuId;
  final String name;
  final int price;
  final String? imageUrl;

  const ProductCard({
    super.key,
    required this.menuId,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuDetailPage(menuId: menuId)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.image)),
                      )
                    : Image.asset(
                        'assets/images/caffelatte.png', // Fallback
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rp$price',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
