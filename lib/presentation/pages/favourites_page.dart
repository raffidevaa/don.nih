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
  List<Map<String, dynamic>> _favouriteItems = [];
  bool _isLoading = true;
  
  // --- VARIABLE SEARCH ---
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchFavorites() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('favorites')
          .select('id, menu_id, menus(id, name, price, img)') 
          .eq('user_id', user.id); 

      if (mounted) {
        setState(() {
          _favouriteItems = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int favoriteId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('favorites').delete().eq('id', favoriteId);
      
      // Refresh data setelah hapus
      fetchFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari favorite'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    }
  }

  Future<void> _addToCart(int menuId, String menuName) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      await supabase.from('cart').insert({
        'id': DateTime.now().millisecondsSinceEpoch, 
        'user_id': user.id,
        'menu_id': menuId,
        'quantity': 1,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$menuName ditambahkan ke keranjang!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sudah ada di keranjang')),
        );
      }
    }
  }

  // --- LOGIKA URL GAMBAR ONLINE (SUPABASE) ---
  String _getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';
    // Pastikan bucket bernama 'menu'
    return Supabase.instance.client.storage.from('menu').getPublicUrl(fileName);
  }

  // --- LOGIKA GAMBAR LOKAL (SESUAI NAMA MENU DI DATABASE) ---
  // Ini fungsi kuncinya! Kita cocokkan Nama Menu dengan File Aset kamu.
  String _getLocalAssetPath(String menuName) {
    final nameLower = menuName.toLowerCase();

    // Mapping sesuai data di tabel menus ke aset laptopmu
    if (nameLower.contains('espresso')) return 'assets/images/espresso.png';
    if (nameLower.contains('americano')) return 'assets/images/americano.png';
    if (nameLower.contains('latte')) return 'assets/images/caffelatte.png';
    if (nameLower.contains('cappuccino')) return 'assets/images/menu_cappucino.png';
    if (nameLower.contains('peach tea')) return 'assets/images/peachtea.png';
    if (nameLower.contains('apple tea')) return 'assets/images/appletea.png';
    if (nameLower.contains('pancake')) return 'assets/images/pancake.png';
    if (nameLower.contains('curry')) return 'assets/images/curry.png';
    
    // Default kalau nama tidak dikenali
    return 'assets/images/caffelatte.png'; 
  }

  // --- LOGIKA FILTER SEARCH ---
  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) {
      return _favouriteItems;
    }
    return _favouriteItems.where((item) {
      final menuData = item['menus'] ?? {};
      final name = (menuData['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredList;

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
                  const Text('Favourites', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, width: 1.5), borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search favourites...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryBrown))
                  : displayList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Icon(Icons.favorite_border, size: 60, color: Colors.grey[300]), 
                              const SizedBox(height: 10), 
                              Text(_searchQuery.isEmpty ? "Belum ada menu favorit" : "Menu tidak ditemukan", style: const TextStyle(color: Colors.grey))
                            ]
                          )
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            final menuData = item['menus'] ?? {};
                            
                            final int favoriteId = item['id'];
                            final int menuId = item['menu_id']; 
                            final String name = menuData['name'] ?? 'Unknown';
                            final String price = (menuData['price'] ?? 0).toString();
                            final String imgFileName = menuData['img'] ?? ''; 

                            final String fullImageUrl = _getImageUrl(imgFileName);

                            return _buildFavouriteCard(
                              favoriteId: favoriteId,
                              menuId: menuId,
                              name: name,
                              price: price,
                              imageUrl: fullImageUrl,
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
    required int favoriteId,
    required int menuId,
    required String name,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: kPrimaryBrown.withOpacity(0.5), width: 1)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // UPDATE: Coba load Online dulu, kalau gagal load Asset Lokal sesuai nama menu
            child: Image.network(
              imageUrl,
              width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                // LOGIKA FALLBACK BARU:
                // Cari gambar lokal berdasarkan nama menu yang ada di database
                return Image.asset(
                  _getLocalAssetPath(name), 
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container( 
                    width: 80, height: 80, color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Rp$price", style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
            ]),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _removeFavorite(favoriteId),
                child: const Icon(Icons.favorite, color: kPrimaryBrown, size: 26),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _addToCart(menuId, name),
                child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: kPrimaryBrown, shape: BoxShape.circle),
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