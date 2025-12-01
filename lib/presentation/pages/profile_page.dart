import 'package:flutter/material.dart';

const Color kGoldColor = Color(0xFF8B6F47);
const Color kDarkBrown = Color(0xFF5c3d2e);
const Color kSoftCream = Color(0xFFFAF3EE);
const Color kGreyText = Color(0xFF9E9E9E);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [

            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 400, 
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kSoftCream,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40), // 
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kDarkBrown,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 120, 
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: kDarkBrown.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kGoldColor, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 65,
                            backgroundImage: AssetImage('assets/images/espresso.png'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: kDarkBrown,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 285,
                  child: Column(
                    children: [
                      Text(
                        "Donny Aja",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kDarkBrown,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Coffee Lover ☕",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Username"),
                  _buildPremiumField(Icons.alternate_email_rounded, "don.nih"),
                  
                  const SizedBox(height: 20),

                  _buildLabel("Full Name"),
                  _buildPremiumField(Icons.person_outline_rounded, "Donny Aja"),

                  const SizedBox(height: 20),

                  _buildLabel("Phone Number"),
                  _buildPremiumField(Icons.phone_iphone_rounded, "0812-3456-7890"),

                  const SizedBox(height: 40),

                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Logout Berhasil")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkBrown,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: kDarkBrown.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Log Out",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kGreyText,
        ),
      ),
    );
  }

  Widget _buildPremiumField(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: kGoldColor, size: 22),
          const SizedBox(width: 15),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: Colors.grey[400], size: 18),
        ],
      ),
    );
  }
}