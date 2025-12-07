import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- WARNA TEMA ---
const Color kPrimaryBrown = Color(0xFF8B6F47);
const Color kDarkBrown = Color(0xFF5c3d2e);

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  // Variabel untuk menyimpan data dari Supabase
  List<Map<String, dynamic>> _favouriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  // --- FUNGSI MENGAMBIL DATA (READ) ---
  Future<void> fetchFavorites() async {
    try {
      final supabase = Supabase.instance.client;

      // UPDATE PENTING DISINI:
      // 1. Nama tabel join diganti jadi 'menus' (sesuai gambar)
      // 2. Kolom gambar diganti jadi 'img' (sesuai gambar)
      final response = await supabase
          .from('favorites')
          .select('id, menu_id, menus(name, price, img)'); 

      // Cek di debug console apakah datanya masuk
      print("Data Favorit: $response");

      if (mounted) {
        setState(() {
          _favouriteItems = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        // Tampilkan pesan error kalau gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // BAGIAN ATAS: Judul & Search Bar
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search favourites...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Icon(Icons.search, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BAGIAN BAWAH: List Makanan (REAL DATA)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryBrown))
                  : _favouriteItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              const Text("Belum ada menu favorit", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: _favouriteItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final item = _favouriteItems[index];
                            
                            // UPDATE PENTING:
                            // Ambil data dari key 'menus' (bukan 'menu')
                            final menuData = item['menus'] ?? {};
                            
                            // Ambil nama kolom 'img' (bukan 'image')
                            // Handle harga: di DB type float/int, perlu diubah ke String
                            String priceStr = "0";
                            if (menuData['price'] != null) {
                              priceStr = menuData['price'].toString();
                            }

                            return _buildFavouriteCard(
                              id: item['id'],
                              name: menuData['name'] ?? 'Unknown',
                              price: priceStr,
                              imageUrl: menuData['img'] ?? '', 
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavouriteCard({
    required int id,
    required String name,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryBrown.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImage(imageUrl), // Fungsi helper untuk gambar
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp$price",
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Ikon Love & Add
          Row(
            children: [
              GestureDetector(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Delete coming soon!")));
                },
                child: const Icon(Icons.favorite, color: kPrimaryBrown, size: 26),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: kPrimaryBrown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk menampilkan Gambar (Network atau Asset)
  Widget _buildImage(String imgPath) {
    // Karena di DB isinya cuma "1_menu.png", bukan URL lengkap.
    // Kita coba tampilkan sebagai asset dulu, atau placeholder kalau bingung.
    
    // Cek apakah ini URL (http)
    if (imgPath.startsWith('http')) {
      return Image.network(
        imgPath, width: 80, height: 80, fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _placeholderImage(),
      );
    } 
    
    // Kalau bukan URL, anggap Asset. 
    // TAPI: nama file di DB kamu "1_menu.png", sedangkan di folder asset mungkin beda.
    // Kita coba load aja, siapa tau Raffi udah siapin.
    return Image.asset(
      "assets/images/$imgPath", // Asumsi file ada di folder assets/images/
      width: 80, height: 80, fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80, height: 80, color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}