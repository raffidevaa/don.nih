import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class CartItem {
  String image;
  String title;
  String subtitle;
  int price;
  int quantity;

  CartItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int currentIndex = 2;

  /// LIST CART DYNAMIC
  List<CartItem> cartItems = [
    CartItem(
      image: "assets/images/menu_cappucino.png",
      title: "Cappuccino",
      subtitle: "Regular, Cold, Extra Espresso",
      price: 58000,
      quantity: 2,
    ),
    CartItem(
      image: "assets/images/menu_cappucino.png",
      title: "Peach Tea",
      subtitle: "Regular, Less Sugar",
      price: 18000,
      quantity: 1,
    ),
    CartItem(
      image: "assets/images/menu_cappucino.png",
      title: "Americano",
      subtitle: "Large, Cold, No Sugar",
      price: 23000,
      quantity: 1,
    ),
    CartItem(
      image: "assets/images/menu_cappucino.png",
      title: "Strawberry Pancake",
      subtitle: "—",
      price: 72000,
      quantity: 2,
    ),
    CartItem(
      image: "assets/images/menu_cappucino.png",
      title: "Japanese Curry",
      subtitle: "Spicy, Chicken",
      price: 42000,
      quantity: 1,
    ),
  ];

  /// TOTAL HARGA OTOMATIS
  int get totalPrice {
    int sum = 0;
    for (var item in cartItems) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  /// FORMAT RUPIAH SEDERHANA
  String rupiah(int number) {
    return "Rp${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Cart",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// CART LOOP
                    for (int i = 0; i < cartItems.length; i++)
                      CartItemWidget(
                        item: cartItems[i],
                        onAdd: () {
                          setState(() {
                            cartItems[i].quantity++;
                          });
                        },
                        onRemove: () {
                          setState(() {
                            if (cartItems[i].quantity > 1) {
                              cartItems[i].quantity--;
                            }
                          });
                        },
                      ),

                    const SizedBox(height: 30),

                    const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Cash", style: TextStyle(fontSize: 16)),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// CHECKOUT TOTAL OTOMATIS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2B10),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: Text(
                        "Check Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        rupiah(totalPrice),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(

            )
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

/// CART ITEM WIDGET
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function() onAdd;
  final Function() onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp${item.price}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemove,
              ),
              Text(
                item.quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
