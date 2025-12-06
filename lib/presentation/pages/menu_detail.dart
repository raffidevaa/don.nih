import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/datasources/cart_datasource.dart';
import '../../data/models/cart_request.dart';

class MenuDetailPage extends StatefulWidget {
  final int? menuId;

  const MenuDetailPage({super.key, this.menuId});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late CartDatasource _cartDatasource;

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _menuRow;

  // UI Values
  String selectedSize = "Regular";
  String selectedTemp = "Cold";
  bool isFavorite = false;

  // Extra toppings
  List<Map<String, dynamic>> toppingList = [];
  final Set<int> selectedToppingIds = {};

  // Excluded topping ids
  final Set<int> excludedToppingIds = {9, 10, 11, 12};

  // Mapping
  final Map<String, int> sizeToId = {'Regular': 11, 'Large': 9};
  final Map<String, int> tempToId = {'Cold': 10, 'Hot': 12};

  // NEW — store size/temp price lookup
  final Map<int, double> sizeTempPrice = {};

  late StorageDatasource _storageDataSource;

  @override
  void initState() {
    super.initState();
    _storageDataSource = StorageDatasource();
    _cartDatasource = CartDatasource();

    _fetchAll();
  }

  Future<void> _fetchAll() async {
    if (widget.menuId == null) {
      setState(() {
        _errorMessage = "menuId is null";
        _isLoading = false;
      });
      return;
    }

    try {
      _isLoading = true;
      setState(() {});

      // Fetch menu
      final menuResp = await supabase
          .from('menus')
          .select('*')
          .eq('id', widget.menuId!)
          .maybeSingle();

      if (menuResp == null) {
        setState(() {
          _errorMessage = "Menu not found";
          _isLoading = false;
        });
        return;
      }

      _menuRow = Map<String, dynamic>.from(menuResp);

      // Fetch toppings excluding size/temp
      String excludeList = excludedToppingIds.join(',');
      final toppingsResp = await supabase
          .from('toppings')
          .select('*')
          .not('id', 'in', '($excludeList)');

      toppingList = (toppingsResp as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // NEW — fetch size & temp rows
      final sizeTempResp = await supabase
          .from('toppings')
          .select('id, price')
          .inFilter('id', excludedToppingIds.toList());

      for (var row in (sizeTempResp as List<dynamic>)) {
        final id = (row['id'] as num).toInt();
        final p = row['price'];
        sizeTempPrice[id] = (p is num)
            ? p.toDouble()
            : double.tryParse(p.toString()) ?? 0;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double get basePrice {
    if (_menuRow == null) return 0;
    final v = _menuRow!['price'];
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  // NEW — clean correct calculation
  double get totalPrice {
    double total = basePrice;

    // Size
    final sizeId = sizeToId[selectedSize];
    total += sizeTempPrice[sizeId] ?? 0;

    // Temp
    final tempId = tempToId[selectedTemp];
    total += sizeTempPrice[tempId] ?? 0;

    // Extra toppings
    for (var t in toppingList) {
      final id = (t['id'] as num).toInt();
      if (selectedToppingIds.contains(id)) {
        final p = t['price'];
        total += (p is num) ? p.toDouble() : double.parse(p.toString());
      }
    }

    return total;
  }

  Future<void> _handleAddToCart() async {
    if (widget.menuId == null) return;

    try {
      setState(() => _isLoading = true);

      final authUser = supabase.auth.currentUser;
      final String userId =
          authUser?.id ?? "00000000-0000-0000-0000-000000000000";

      // 🔥 gabungkan topping + size + temp
      final sizeId = sizeToId[selectedSize]!;
      final tempId = tempToId[selectedTemp]!;

      final List<int> combinedToppings = [
        ...selectedToppingIds,
        sizeId,
        tempId,
      ];

      // 🔥 gunakan datasource
      await _cartDatasource.addToCart(
        CartRequest(
          userId: userId,
          menuId: widget.menuId!,
          toppings: combinedToppings,
        ),
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to cart")));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add cart: $e")));
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _menuRow == null ||
        toppingList.isEmpty ||
        sizeTempPrice.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    final menuName = _menuRow?['name'] ?? "Menu";
    final menuImage = _menuRow?['img'];
    final displayImage = menuImage != null && menuImage.startsWith("http")
        ? menuImage
        : _storageDataSource.getImageUrl(
            id: _menuRow?['id'].toString() ?? "unknown",
            folderName: "menu",
            fileType: "png",
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================
            // IMAGE + TOP BUTTONS
            // =====================
            Stack(
              children: [
                Image.network(
                  displayImage,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 100),
                  ),
                ),

                // Back
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

                // Favorite
                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => setState(() => isFavorite = !isFavorite),
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

            // =====================
            // MAIN CONTENT
            // =====================
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================
                    // NAME
                    // =====================
                    Text(
                      menuName,
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =====================
                    // SIZE
                    // =====================
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
                          selectedSize == "Regular",
                          () => setState(() => selectedSize = "Regular"),
                        ),
                        const SizedBox(width: 12),
                        _optionButton(
                          "Large",
                          selectedSize == "Large",
                          () => setState(() => selectedSize = "Large"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =====================
                    // TEMP
                    // =====================
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
                          selectedTemp == "Cold",
                          () => setState(() => selectedTemp = "Cold"),
                        ),
                        const SizedBox(width: 12),
                        _optionButton(
                          "Hot",
                          selectedTemp == "Hot",
                          () => setState(() => selectedTemp = "Hot"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =====================
                    // TOPPINGS
                    // =====================
                    const Text(
                      "Toppings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (toppingList.isEmpty)
                      const Text("No extra toppings")
                    else
                      ...toppingList.map((t) {
                        final id = (t['id'] as num).toInt();
                        final name = t['name'];
                        final price = t['price'];
                        final selected = selectedToppingIds.contains(id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Text("Rp$price"),
                                  Checkbox(
                                    value: selected,
                                    activeColor: Colors.brown,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          selectedToppingIds.add(id);
                                        } else {
                                          selectedToppingIds.remove(id);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 30),

                    // =====================
                    // ADD TO CART BUTTON
                    // =====================
                    GestureDetector(
                      onTap: _handleAddToCart,
                      child: Container(
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
}
