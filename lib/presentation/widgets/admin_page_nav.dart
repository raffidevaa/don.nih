import 'package:flutter/material.dart';

class AdminPageNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminPageNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF422110), // Background color from Figma
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(
              icon: Icons.home,
              label: "Home",
              index: 0,
            ),
            _navItem(
              icon: Icons.assignment,
              label: "Order",
              index: 1,
            ),
            _navItem(
              icon: Icons.person,
              label: "Profile",
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
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
          // Icon dengan gradasi
          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFCB8A58),
                      Color(0xFF562B1A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
          const SizedBox(height: 5),
          // Text dengan gradasi
          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFCB8A58),
                      Color(0xFF562B1A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Lato',
                    ),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Lato',
                  ),
                ),
        ],
      ),
    );
  }
}
