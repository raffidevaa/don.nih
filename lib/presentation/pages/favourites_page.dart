import 'package:flutter/material.dart';

class DummyProduct {
  final String name;
  final String price;
  final String image; 

  DummyProduct({required this.name, required this.price, required this.image});
}

final List<DummyProduct> dummyFavourites = [
  DummyProduct(
    name: "Cappuccino",
    price: "Rp20.000",
    image: "assets/images/menu_cappucino.png", 
  ),
  DummyProduct(
    name: "Apple Tea",
    price: "Rp18.000",
    image: "assets/images/appletea.png", 
  ),
  DummyProduct(
    name: "Strawberry Pancake",
    price: "Rp36.000",
    image: "assets/images/pancake.png", 
  ),
  DummyProduct(
    name: "Japanese Curry",
    price: "Rp42.000",
    image: "assets/images/curry.png", 
  ),
];

const Color kPrimaryBrown = Color(0xFF8B6F47);
const Color kDarkBrown = Color(0xFF5c3d2e);

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white, 
      body: SafeArea( 
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favourites',
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
                        hintText: 'Search favourites...',
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

            // List Makanan
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: dummyFavourites.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final product = dummyFavourites[index];
                  return _buildFavouriteCard(product, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(DummyProduct product, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryBrown.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              product.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80, height: 80, color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, color: kPrimaryBrown, size: 26),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: kPrimaryBrown,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}