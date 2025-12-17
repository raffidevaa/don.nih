import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/cart_datasource.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/models/cart_request.dart';

class MenuDetailPage extends StatefulWidget {
  final int? menuId;

  const MenuDetailPage({super.key, this.menuId});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final supabase = Supabase.instance.client;

  late CartDatasource _cartDatasource;
  late StorageDatasource _storageDatasource;

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _menu;

  /// UI state
  String selectedSize = "Regular";
  String selectedTemp = "Cold";
  bool isFavorite = false;

  /// toppings
  List<Map<String, dynamic>> toppingList = [];
  final Set<int> selectedToppingIds = {};

  /// excluded = size & temp
  final Set<int> excludedToppingIds = {9, 10, 11, 12};

  /// mapping label → topping id
  final Map<String, int> sizeToId = {'Regular': 11, 'Large': 9};
  final Map<String, int> tempToId = {'Cold': 10, 'Hot': 12};

  /// price lookup
  final Map<int, double> sizeTempPrice = {};

  @override
  void initState() {
    super.initState();
    _cartDatasource = CartDatasource();
    _storageDatasource = StorageDatasource();

    _fetchAll();
    _checkIfFavorite();
  }

  // ================= FETCH =================

  Future<void> _fetchAll() async {
    if (widget.menuId == null) {
      _errorMessage = "menuId is null";
      _isLoading = false;
      setState(() {});
      return;
    }

    try {
      _isLoading = true;
      setState(() {});

      /// menu
      final menuResp = await supabase
          .from('menus')
          .select('*')
          .eq('id', widget.menuId!)
          .maybeSingle();

      if (menuResp == null) {
        _errorMessage = "Menu not found";
        _isLoading = false;
        setState(() {});
        return;
      }

      _menu = Map<String, dynamic>.from(menuResp);

      /// toppings (exclude size/temp)
      final exclude = excludedToppingIds.join(',');
      final toppingResp = await supabase
          .from('toppings')
          .select('*')
          .not('id', 'in', '($exclude)');

      toppingList = (toppingResp as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      /// size & temp prices
      final sizeTempResp = await supabase
          .from('toppings')
          .select('id, price')
          .inFilter('id', excludedToppingIds.toList());

      for (var r in sizeTempResp) {
        sizeTempPrice[r['id']] = (r['price'] as num).toDouble();
      }

      _isLoading = false;
      setState(() {});
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      setState(() {});
    }
  }

  // ================= FAVORITE =================

  Future<void> _checkIfFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null || widget.menuId == null) return;

    final data = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('menu_id', widget.menuId!)
        .maybeSingle();

    setState(() => isFavorite = data != null);
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null || widget.menuId == null) return;

    setState(() => isFavorite = !isFavorite);

    try {
      if (isFavorite) {
        await supabase.from('favorites').insert({
          'id': DateTime.now().millisecondsSinceEpoch,
          'user_id': user.id,
          'menu_id': widget.menuId!,
        });
      } else {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('menu_id', widget.menuId!);
      }
    } catch (e) {
      setState(() => isFavorite = !isFavorite);
    }
  }

  // ================= PRICE =================

  double get basePrice => (_menu?['price'] as num?)?.toDouble() ?? 0;

  double get totalPrice {
    double total = basePrice;
    total += sizeTempPrice[sizeToId[selectedSize]] ?? 0;
    total += sizeTempPrice[tempToId[selectedTemp]] ?? 0;

    for (var t in toppingList) {
      final id = t['id'] as int;
      if (selectedToppingIds.contains(id)) {
        total += (t['price'] as num).toDouble();
      }
    }
    return total;
  }

  // ================= ADD TO CART =================

  Future<void> _handleAddToCart() async {
    final user = supabase.auth.currentUser;
    if (user == null || widget.menuId == null) return;

    final combinedToppings = [
      ...selectedToppingIds,
      sizeToId[selectedSize]!,
      tempToId[selectedTemp]!,
    ];

    await _cartDatasource.addToCart(
      CartRequest(
        userId: user.id,
        menuId: widget.menuId!,
        toppings: combinedToppings,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to cart")));
  }

  // ================= UI =================

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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

    final imageUrl = _storageDatasource.getImageUrl(
      id: _menu!['id'].toString(),
      folderName: "menu",
      fileType: "png",
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.brown),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.brown,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _menu!['name'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Size",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    const Text(
                      "Temperature",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    const Text(
                      "Toppings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...toppingList.map((t) {
                      final id = t['id'] as int;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t['name']),
                          Row(
                            children: [
                              Text("Rp${t['price']}"),
                              Checkbox(
                                value: selectedToppingIds.contains(id),
                                onChanged: (v) {
                                  setState(() {
                                    v == true
                                        ? selectedToppingIds.add(id)
                                        : selectedToppingIds.remove(id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 30),
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
