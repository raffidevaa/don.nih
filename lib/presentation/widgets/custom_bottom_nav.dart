import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: Color(0xFF422110)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(icon: Icons.home, label: "Home", index: 0),
          navItem(icon: Icons.favorite, label: "Favourite", index: 1),
          navItem(icon: Icons.shopping_cart, label: "Cart", index: 2),
          navItem(icon: Icons.person, label: "Profile", index: 3),
          navItem(icon: Icons.list, label: "Order Status", index: 4),
        ],
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? const Color(0xFFD2AE82) : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFD2AE82) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
