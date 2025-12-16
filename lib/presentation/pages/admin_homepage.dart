import 'package:flutter/material.dart';
import 'admin_menu_detail_page.dart';
import 'admin_add_menu_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample menu data
  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Espresso',
      'price': 'Rp9.000',
      'image': 'assets/images/espresso.png',
      'category': 'coffee',
      'description': 'Rich and bold espresso shot.',
    },
    {
      'name': 'Americano',
      'price': 'Rp18.000',
      'image': 'assets/images/americano.png',
      'category': 'coffee',
      'description': 'Espresso diluted with hot water.',
    },
    {
      'name': 'Cafe Latte',
      'price': 'Rp20.000',
      'image': 'assets/images/cafe_latte.png',
      'category': 'coffee',
      'description': 'Espresso with steamed milk.',
    },
    {
      'name': 'Cappuccino',
      'price': 'Rp20.000',
      'image': 'assets/images/cappuccino.png',
      'category': 'coffee',
      'description': 'Espresso, Steamed Milk, and Frothed Milk.',
    },
    {
      'name': 'Peach Tea',
      'price': 'Rp18.000',
      'image': 'assets/images/peach_tea.png',
      'category': 'tea',
      'description': 'Refreshing peach flavored tea.',
    },
    {
      'name': 'Apple Tea',
      'price': 'Rp18.000',
      'image': 'assets/images/apple_tea.png',
      'category': 'tea',
      'description': 'Sweet apple flavored tea.',
    },
    {
      'name': 'Strawberry Pancake',
      'price': 'Rp36.000',
      'image': 'assets/images/strawberry_pancake.png',
      'category': 'food',
      'description': 'Fluffy pancakes with fresh strawberries.',
    },
    {
      'name': 'Japanese Curry',
      'price': 'Rp42.000',
      'image': 'assets/images/japanese_curry.png',
      'category': 'food',
      'description': 'Traditional Japanese curry with rice.',
    },
  ];

  List<Map<String, dynamic>> get filteredMenuItems {
    if (_searchQuery.isEmpty) return menuItems;
    return menuItems.where((item) {
      return item['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home page
        break;
      case 1:
        Navigator.pushNamed(context, '/admin-order-status');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin-profile');
        break;
    }
  }

  void _navigateToMenuDetail(Map<String, dynamic> menuItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminMenuDetailPage(menuItem: menuItem),
      ),
    );
  }

  void _addNewMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAddMenuPage(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Title
                      const Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 15),

                      // Add Menu Button
                      _buildAddMenuButton(),
                      const SizedBox(height: 20),

                      // Menu Grid
                      _buildMenuGrid(),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFCB8A58),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: TextStyle(
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.grey.shade400,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMenuButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: _addNewMenu,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCB8A58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Add Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final items = filteredMenuItems;
    
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No menu items found',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(items[index]);
      },
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menuItem) {
    return GestureDetector(
      onTap: () => _navigateToMenuDetail(menuItem),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFCB8A58),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Edit Icon
            Expanded(
              child: Stack(
                children: [
                  // Image Placeholder
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: Image.asset(
                        menuItem['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Edit Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _navigateToMenuDetail(menuItem),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCB8A58),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    menuItem['price'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF666666),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF422110),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Order', 1),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFFCB8A58) : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? const Color(0xFFCB8A58) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}