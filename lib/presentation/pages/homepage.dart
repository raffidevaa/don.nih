import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _selectedCategory;

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Espresso',
      'price': 9000,
      'image': 'assets/images/espresso.png',
      'category': 'COFFEE',
    },
    {
      'name': 'Americano',
      'price': 18000,
      'image': 'assets/images/americano.png',
      'category': 'COFFEE',
    },
    {
      'name': 'Cafe Latte',
      'price': 20000,
      'image': 'assets/images/caffelatte.png',
      'category': 'COFFEE',
    },
    {
      'name': 'Cappuccino',
      'price': 20000,
      'image': 'assets/images/menu_cappucino.png',
      'category': 'COFFEE',
    },
    {
      'name': 'Peach Tea',
      'price': 18000,
      'image': 'assets/images/peachtea.png',
      'category': 'NON-COFFEE',
    },
    {
      'name': 'Apple Tea',
      'price': 18000,
      'image': 'assets/images/appletea.png',
      'category': 'NON-COFFEE',
    },
    {
      'name': 'Strawberry Pancake',
      'price': 36000,
      'image': 'assets/images/pancake.png',
      'category': 'DESSERT',
    },
    {
      'name': 'Japanese Curry',
      'price': 42000,
      'image': 'assets/images/curry.png',
      'category': 'MEAL',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (_selectedCategory == null) {
      return products;
    }
    return products
        .where((product) => product['category'] == _selectedCategory)
        .toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Welcome
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Donny!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
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
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Categories Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                    child: const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Category Chips
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
                  // Products Grid
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
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          name: product['name'],
                          price: product['price'],
                          image: product['image'],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5c3d2e),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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

class ProductCard extends StatefulWidget {
  final String name;
  final int price;
  final String image;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  widget.image,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
              // Favorite Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() => isFavorite = !isFavorite);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp${widget.price.toString()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.name} added to cart'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6F47),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
