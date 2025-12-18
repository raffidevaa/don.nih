import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/admin_page_nav.dart';

// --- WARNA TEMA ---
const Color kGoldColor = Color(0xFF8B6F47);
const Color kDarkBrown = Color(0xFF5c3d2e);
const Color kGreyText = Color(0xFF9E9E9E);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel Data User
  String _fullName = "Loading...";
  String _username = "Loading...";
  String _email = "";
  String _phone = "-";
  String? _avatarUrl;
  String _role = "user"; // Default role
  
  bool _isLoading = true;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // --- 1. AMBIL DATA PROFILE ---
  Future<void> _getProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      _email = user.email ?? "";

      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _fullName = data?['fullname'] ?? "No Name";
          _username = data?['username'] ?? "User";
          _phone = data?['phone_number'] ?? "-";
          _avatarUrl = data?['avatar_url'];
          _role = data?['role'] ?? "user"; // Fetch role from database
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. UPLOAD & GANTI FOTO ---
  Future<void> _uploadPhoto() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final imageBytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('avatars').uploadBinary(
        fileName,
        imageBytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase.from('users').update({
        'avatar_url': imageUrl
      }).eq('id', user.id);

      setState(() {
        _avatarUrl = imageUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diupdate!")),
        );
      }

    } catch (e) {
      print("Upload error: $e");
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload: $e")),
        );
      }
    }
  }

  // --- 3. EDIT NAMA / HP (DIALOG) ---
  Future<void> _showEditDialog(String fieldName, String currentValue, String dbColumn) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Masukkan $fieldName baru",
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(dbColumn, controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkBrown,
                foregroundColor: Colors.white,
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi Update Data ke Supabase
  Future<void> _updateProfile(String column, String value) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').update({
        column: value
      }).eq('id', user.id);

      setState(() {
        if (column == 'fullname') _fullName = value;
        if (column == 'phone_number') _phone = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update: $e")),
      );
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: _role == 'admin'
          ? AdminPageNav(
              currentIndex: 2, // Profile is index 2 for admin
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/admin/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/admin/orders');
                }
                // index 2 is current page (profile)
              },
            )
          : BottomNavigationBar(
              currentIndex: 3, // Profile is index 3 for user
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/favourites');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/cart');
                }
                // index 3 is current page (profile)
              },
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkBrown))
          : SafeArea( 
              child: SingleChildScrollView(
                child: Center( 
                  child: Column(
                    children: [
                      const SizedBox(height: 30), 

                      // 1. JUDUL
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kDarkBrown,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 2. AVATAR SECTION
                      Stack(
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
                            child: _isUploading
                                ? const CircleAvatar(
                                    radius: 65,
                                    backgroundColor: Colors.grey,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : CircleAvatar(
                                    radius: 65,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                        ? NetworkImage(_avatarUrl!) as ImageProvider
                                        : const AssetImage('assets/images/espresso.png'),
                                  ),
                          ),
                          // Tombol Edit Foto
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: _uploadPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: kDarkBrown,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 3. NAMA & USERNAME
                      Text(
                        _fullName,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold, color: kDarkBrown),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "@$_username",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 50), // Spasi sebelum form

                      // 4. FORM FIELDS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Email"),
                            _buildField(Icons.alternate_email_rounded, _email, isEditable: false),

                            const SizedBox(height: 20),

                            _buildLabel("Full Name"),
                            _buildField(
                              Icons.person_outline_rounded, 
                              _fullName, 
                              isEditable: true,
                              onTap: () => _showEditDialog("Full Name", _fullName, 'fullname'),
                            ),

                            const SizedBox(height: 20),

                            _buildLabel("Phone Number"),
                            _buildField(
                              Icons.phone_iphone_rounded, 
                              _phone, 
                              isEditable: true,
                              onTap: () => _showEditDialog("Phone Number", _phone, 'phone_number'),
                            ),

                            const SizedBox(height: 40),

                            // LOGOUT
                            Center(
                              child: SizedBox(
                                width: 200, height: 52,
                                child: ElevatedButton(
                                  onPressed: _signOut,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kDarkBrown,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shadowColor: kDarkBrown.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.logout_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kGreyText)),
    );
  }

  Widget _buildField(IconData icon, String value, {required bool isEditable, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isEditable)
            GestureDetector(
              onTap: onTap,
              child: const Icon(Icons.edit, color: kGoldColor, size: 20),
            ),
        ],
      ),
    );
  }
}