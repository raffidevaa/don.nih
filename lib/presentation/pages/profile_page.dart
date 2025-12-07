import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- WARNA TEMA ---
const Color kGoldColor = Color(0xFF8B6F47);
const Color kDarkBrown = Color(0xFF5c3d2e);
const Color kSoftCream = Color(0xFFFAF3EE);
const Color kGreyText = Color(0xFF9E9E9E);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel untuk menampung data profil
  String _fullName = "Loading...";
  String _username = "Loading...";
  String _email = "";
  String _phone = "-";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // --- 1. ENDPOINT GET PROFILE ---
  Future<void> _getProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        // Kalau user belum login (Guest)
        setState(() {
          _fullName = "Guest User";
          _username = "guest";
          _isLoading = false;
        });
        return;
      }

      // Simpan email dari auth (karena email ada di auth, bukan tabel users biasanya)
      _email = user.email ?? "";

      // Ambil data detail dari tabel 'users' berdasarkan ID login
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          // Ambil data, kalau null kasih strip (-)
          _fullName = data?['fullname'] ?? "No Name";
          _username = data?['username'] ?? _email.split('@')[0]; // Fallback ke nama depan email
          _phone = data?['phone_number'] ?? "-";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetch profile: $e");
      if (mounted) {
        setState(() {
          _fullName = "Error Loading";
          _isLoading = false;
        });
      }
    }
  }

  // --- 2. FUNGSI LOGOUT ---
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        // Kembali ke halaman Login dan hapus semua history halaman sebelumnya
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Logout: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkBrown))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Background Cream Melengkung
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

                      // Judul My Profile
                      const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
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

                      // Foto Profil
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
                                  // Sementara masih pakai asset statis
                                  backgroundImage: AssetImage('assets/images/espresso.png'),
                                ),
                              ),
                            ),
                            // Tombol Edit Kecil
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

                      // Nama & Role (DATA DARI SUPABASE)
                      Positioned(
                        top: 285,
                        child: Column(
                          children: [
                            Text(
                              _fullName, 
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: kDarkBrown,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "@$_username",
                              style: const TextStyle(
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

                  // Form Fields (DATA DARI SUPABASE)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Email"),
                        _buildPremiumField(Icons.alternate_email_rounded, _email),

                        const SizedBox(height: 20),

                        _buildLabel("Full Name"),
                        _buildPremiumField(Icons.person_outline_rounded, _fullName),

                        const SizedBox(height: 20),

                        _buildLabel("Phone Number"),
                        _buildPremiumField(Icons.phone_iphone_rounded, _phone),

                        const SizedBox(height: 40),

                        // Tombol Logout (SUDAH AKTIF)
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _signOut, // <--- Panggil fungsi Logout
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