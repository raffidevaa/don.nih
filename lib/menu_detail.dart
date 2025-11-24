import 'package:flutter/material.dart';

class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({super.key});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  String size = "Regular";
  String temperature = "Cold";
  bool isFavorite = false;

  Map<String, bool> toppings = {
    "Extra Espresso": true,
    "Whipped Cream": false,
    "Oreo": false,
    "Vanilla Syrup": false,
    "Caramel Syrup": false,
    "Hazelnut Syrup": false,
    "Salted Caramel Sauce": false,
    "Nata de Coco": false,
  };

  Map<String, int> toppingPrice = {
    "Extra Espresso": 9000,
    "Whipped Cream": 3000,
    "Oreo": 6000,
    "Vanilla Syrup": 6000,
    "Caramel Syrup": 6000,
    "Hazelnut Syrup": 6000,
    "Salted Caramel Sauce": 6000,
    "Nata de Coco": 8000,
  };

  int basePrice = 20000;

  int get totalPrice {
    int toppingTotal = toppings.entries
        .where((e) => e.value)
        .fold(0, (sum, e) => sum + toppingPrice[e.key]!);
    return basePrice + toppingTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // GAMBAR ATAS
                Image.asset(
                  "assets/images/menu_cappucino.png",
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),

                // Tombol back
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.brown),
                    ),
                  ),
                ),

                // Tombol favorit
                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => isFavorite = !isFavorite);
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.brown,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CARD PUTIH OVERLAP GAMBAR
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    Text(
                      "Cappuccino",
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Espresso, Steamed Milk, and Frothed Milk.",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Size",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _optionButton(
                          "Regular",
                          size == "Regular",
                          () => setState(() => size = "Regular"),
                        ),
                        const SizedBox(width: 12),
                        _optionButton(
                          "Large",
                          size == "Large",
                          () => setState(() => size = "Large"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Temperature",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _optionButton(
                          "Cold",
                          temperature == "Cold",
                          () => setState(() => temperature = "Cold"),
                        ),
                        const SizedBox(width: 12),
                        _optionButton(
                          "Hot",
                          temperature == "Hot",
                          () => setState(() => temperature = "Hot"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Toppings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...toppings.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(key, style: const TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text("Rp${toppingPrice[key]}"),
                                Checkbox(
                                  value: toppings[key],
                                  activeColor: Colors.brown,
                                  onChanged: (v) {
                                    setState(() => toppings[key] = v!);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),

                    // TOMBOL ADD TO CART
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade700,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Add to Cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white54,
                          ),
                          Text(
                            "Rp${totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.brown : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.brown.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.brown.shade700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
