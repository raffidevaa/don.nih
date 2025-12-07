import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import ini sudah disesuaikan agar tidak merah
import 'package:donnih/data/datasources/menu_datasource.dart';
import 'package:donnih/data/models/menu_model.dart';

class MenuDetailPage extends StatefulWidget {
  final int? menuId; // ID menu yang akan di-fetch

  const MenuDetailPage({super.key, this.menuId});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  // Pilihan Default User
  String size = "Regular";
  String temperature = "Cold";
  
  bool isFavorite = false; // Status lokal

  // Data dari Supabase
  late MenuDataSource _menuDataSource;
  MenuModel? _menu;
  bool _isLoading = true;
  String? _errorMessage;

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

  /// Base price dari menu
  int get basePrice => _menu?.price.toInt() ?? 20000;

  int get totalPrice {
    int toppingTotal = toppings.entries
        .where((e) => e.value)
        .fold(0, (sum, e) => sum + toppingPrice[e.key]!);
    return basePrice + toppingTotal;
  }

  @override
  void initState() {
    super.initState();
    _menuDataSource = MenuDataSource(Supabase.instance.client);
    _fetchMenuDetail();
    _checkIfFavorite(); // Cek status favorite saat dibuka
  }

  // --- 1. FUNGSI CEK STATUS FAVORITE ---
  Future<void> _checkIfFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || widget.menuId == null) return;

    try {
      final data = await Supabase.instance.client
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('menu_id', widget.menuId!)
          .maybeSingle(); 

      if (mounted) {
        setState(() {
          isFavorite = data != null; // True jika data ditemukan
        });
      }
    } catch (e) {
      print("Error checking favorite: $e");
    }
  }

  // --- 2. FUNGSI TOGGLE (INSERT / DELETE) ---
  Future<void> _toggleFavorite() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (widget.menuId == null) return;

    // Optimistic UI Update
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        // INSERT
        await supabase.from('favorites').insert({
          'id': DateTime.now().millisecondsSinceEpoch,
          'user_id': user.id,
          'menu_id': widget.menuId,
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ditambahkan ke Favorite ❤️'), duration: Duration(seconds: 1)),
          );
        }
      } else {
        // DELETE
        await supabase.from('favorites').delete()
            .eq('user_id', user.id)
            .eq('menu_id', widget.menuId!);
        
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dihapus dari Favorite'), duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite; // Revert jika error
      });
      print("Error toggle favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  Future<void> _fetchMenuDetail() async {
    if (widget.menuId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final menu = await _menuDataSource.getMenuById(widget.menuId!);

      if (menu == null) {
        setState(() {
          _errorMessage = 'Menu not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _menu = menu;
        // PERBAIKAN DI SINI:
        // Kita set default saja, jangan ambil dari menu.size karena kolomnya tidak ada
        size = "Regular"; 
        temperature = "Cold";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Fungsi ganti size (Hanya update tampilan, tidak fetch ulang data)
  void _onSizeChanged(String newSize) {
    setState(() {
      size = newSize;
    });
  }

  String _getImageForMenu(String? menuName) {
    if (menuName == null) return 'assets/images/menu_cappucino.png';
    final name = menuName.toLowerCase();
    
    if (name.contains('espresso')) return 'assets/images/espresso.png';
    if (name.contains('americano')) return 'assets/images/americano.png';
    if (name.contains('latte')) return 'assets/images/caffelatte.png';
    if (name.contains('cappuccino')) return 'assets/images/menu_cappucino.png';
    if (name.contains('peach')) return 'assets/images/peachtea.png';
    if (name.contains('apple')) return 'assets/images/appletea.png';
    if (name.contains('pancake')) return 'assets/images/pancake.png';
    if (name.contains('curry')) return 'assets/images/curry.png';
    
    return 'assets/images/menu_cappucino.png';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMenuDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  _getImageForMenu(_menu?.name),
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.brown),
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleFavorite, 
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

            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _menu?.name ?? "Menu",
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Espresso, Steamed Milk, and Frothed Milk.", style: TextStyle(color: Colors.black54, fontSize: 15)),
                    
                    const SizedBox(height: 25),
                    const Text("Size", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _optionButton("Regular", size == "Regular", () => _onSizeChanged("Regular")),
                        const SizedBox(width: 12),
                        _optionButton("Large", size == "Large", () => _onSizeChanged("Large")),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text("Temperature", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _optionButton("Cold", temperature == "Cold", () => setState(() => temperature = "Cold")),
                        const SizedBox(width: 12),
                        _optionButton("Hot", temperature == "Hot", () => setState(() => temperature = "Hot")),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text("Toppings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  onChanged: (v) => setState(() => toppings[key] = v!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: Colors.brown.shade700, borderRadius: BorderRadius.circular(40)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                          Container(width: 1, height: 24, color: Colors.white54),
                          Text("Rp${totalPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            style: TextStyle(color: selected ? Colors.white : Colors.brown.shade700, fontSize: 16),
          ),
        ),
      ),
    );
  }
}