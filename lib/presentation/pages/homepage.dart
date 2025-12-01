import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'favourites_page.dart'; 
import 'profile_page.dart';
import 'cart_page.dart';
import 'menu_detail.dart';
import '../../data/datasources/menu_datasource.dart';
import '../../data/models/menu_model.dart';

class HomePage extends StatefulWidget {
  // Tambahkan variabel ini untuk menerima pesan "Mau buka tab nomor berapa?"
  final int initialIndex; 

  // Set default-nya 0 (Home), jadi kalau ga diisi dia buka Home biasa
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Hapus inisialisasi langsung (int _selectedIndex = 0;)
  late int _selectedIndex; 
  String? _selectedCategory;

  // Data dari Supabase
  late MenuDataSource _menuDataSource;
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Ambil nilai dari "pesan" yang dikirim saat HomePage dibuka
    _selectedIndex = widget.initialIndex;
    
    // Inisialisasi MenuDataSource dengan Supabase client
    _menuDataSource = MenuDataSource(Supabase.instance.client);
    _fetchMenus();
  }

  /// Fetch semua menu dari Supabase
  Future<void> _fetchMenus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final menus = await _menuDataSource.getAllMenu();
      
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Helper untuk mapping nama menu ke image asset (sementara static)
  String _getImageForMenu(String menuName) {
    final name = menuName.toLowerCase();
    if (name.contains('espresso')) return 'assets/images/espresso.png';
    if (name.contains('americano')) return 'assets/images/americano.png';
    if (name.contains('latte')) return 'assets/images/caffelatte.png';
    if (name.contains('cappuccino')) return 'assets/images/menu_cappucino.png';
    if (name.contains('peach')) return 'assets/images/peachtea.png';
    if (name.contains('apple')) return 'assets/images/appletea.png';
    if (name.contains('pancake')) return 'assets/images/pancake.png';
    if (name.contains('curry')) return 'assets/images/curry.png';
    if (name.contains('green tea')) return 'assets/images/greentea.png';
    if (name.contains('caramel')) return 'assets/images/caramel.png';
    // Default image
    return 'assets/images/caffelatte.png';
  }

  /// Helper untuk mapping nama menu ke category (sementara static)
  String _getCategoryForMenu(String menuName) {
    final name = menuName.toLowerCase();
    // COFFEE
    if (name.contains('espresso') || 
        name.contains('americano') || 
        name.contains('latte') || 
        name.contains('cappuccino') ||
        name.contains('mocha') ||
        name.contains('coffee')) {
      return 'COFFEE';
    }
    // NON-COFFEE
    if (name.contains('tea') || 
        name.contains('matcha') ||
        name.contains('chocolate') ||
        name.contains('milk')) {
      return 'NON-COFFEE';
    }
    // DESSERT
    if (name.contains('pancake') || 
        name.contains('cake') || 
        name.contains('waffle') ||
        name.contains('ice cream') ||
        name.contains('pudding')) {
      return 'DESSERT';
    }
    // BREAKFAST
    if (name.contains('toast') || 
        name.contains('egg') || 
        name.contains('sandwich') ||
        name.contains('croissant')) {
      return 'BREAKFAST';
    }
    // MEAL
    if (name.contains('curry') || 
        name.contains('rice') || 
        name.contains('pasta') ||
        name.contains('noodle') ||
        name.contains('chicken') ||
        name.contains('beef')) {
      return 'MEAL';
    }
    return 'COFFEE'; // default
  }

  /// Group menu by nama (ambil 1 saja per nama menu) + filter by category
  List<MenuModel> get filteredMenus {
    // Group by name, ambil yang pertama saja per nama
    final Map<String, MenuModel> uniqueMenus = {};
    for (var menu in _menus) {
      if (!uniqueMenus.containsKey(menu.name)) {
        uniqueMenus[menu.name] = menu;
      }
    }
    
    // Filter by selected category
    if (_selectedCategory == null) {
      return uniqueMenus.values.toList();
    }
    
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
      case 0: return _buildOriginalHomeUI();
      case 1: return const FavouritesPage(); // Tab Favourite
      case 2: return const CartPage();       // Tab Cart
      case 3: return const ProfilePage(); // Tab Profile
      default: return _buildOriginalHomeUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5c3d2e),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourite'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOriginalHomeUI() {
    // ... (KODE UI HOME ASLI TEMANMU TETAP SAMA DISINI, TIDAK ADA YANG BERUBAH)
    // Supaya tidak kepanjangan, aku singkat ya.
    // Isinya COPY PASTE saja dari function _buildOriginalHomeUI yang sebelumnya aku kasih.
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome, Donny!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, width: 1.5), borderRadius: BorderRadius.circular(30)),
                child: TextField(decoration: InputDecoration(hintText: 'Search menu ...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), hintStyle: TextStyle(color: Colors.grey[400]), suffixIcon: Icon(Icons.search, color: Colors.grey[400]))),
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
                const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 15), child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: [
                      CategoryChip(icon: '☕', label: 'COFFEE', isSelected: _selectedCategory == 'COFFEE', onTap: () => _onCategorySelected('COFFEE')),
                      CategoryChip(icon: '🥤', label: 'NON-COFFEE', isSelected: _selectedCategory == 'NON-COFFEE', onTap: () => _onCategorySelected('NON-COFFEE')),
                      CategoryChip(icon: '🍰', label: 'DESSERT', isSelected: _selectedCategory == 'DESSERT', onTap: () => _onCategorySelected('DESSERT')),
                      CategoryChip(icon: '🍳', label: 'BREAKFAST', isSelected: _selectedCategory == 'BREAKFAST', onTap: () => _onCategorySelected('BREAKFAST')),
                      CategoryChip(icon: '🍽️', label: 'MEAL', isSelected: _selectedCategory == 'MEAL', onTap: () => _onCategorySelected('MEAL')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85),
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      final menu = filteredMenus[index];
                      return ProductCard(
                        menuId: menu.id,
                        name: menu.name,
                        price: menu.price.toInt(),
                        image: _getImageForMenu(menu.name),
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

// (Jangan lupa tetap sertakan class CategoryChip dan ProductCard di bawahnya seperti sebelumnya)
class CategoryChip extends StatelessWidget {
  final String icon; final String label; final bool isSelected; final VoidCallback onTap;
  const CategoryChip({super.key, required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF8B6F47) : Colors.grey[300]!, width: 1.5),
          borderRadius: BorderRadius.circular(25),
          color: isSelected ? const Color(0xFFFAF3EE) : Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Text(icon, style: const TextStyle(fontSize: 16)), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF8B6F47) : Colors.black54))]),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final int menuId;
  final String name;
  final int price;
  final String image;

  const ProductCard({
    super.key,
    required this.menuId,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate ke MenuDetailPage dengan menuId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(menuId: menuId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!, width: 1.5), color: Colors.white),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)), child: Image.asset(image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.image))))),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1), const SizedBox(height: 5), Text('Rp$price', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))])),
        ]),
      ),
    );
  }
}