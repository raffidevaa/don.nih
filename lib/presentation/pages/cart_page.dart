import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/datasources/cart_datasource.dart';
import '../../data/models/create_order_request.dart';
import '../../data/datasources/order_datasource.dart';

/// UI MODEL
class CartItem {
  int cartId;
  String image;
  String title;
  String subtitle;
  double price;
  int quantity;
  int menuToppingId;

  CartItem({
    required this.cartId,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.menuToppingId,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final StorageDatasource storage = StorageDatasource();
  final CartDatasource cartDatasource = CartDatasource();
  bool loading = true;
  bool checkoutLoading = false;

  List<CartItem> cartItems = [];
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final authUser = supabase.auth.currentUser;
      final String userId =
          authUser?.id ?? "00000000-0000-0000-0000-000000000000";

      final response = await cartDatasource.getCartItems(userId);

      cartItems = response.map((r) {
        return CartItem(
          cartId: r.cartId,
          image: r.menuImage,
          title: r.menuName,
          subtitle: r.toppings.isEmpty ? "—" : r.toppings.join(", "),
          price: r.baseTotal,
          quantity: 1,
          menuToppingId: r.menuToppingId,
        );
      }).toList();
    } catch (e) {
      throw ("Error loading cart: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _confirmDeleteCart(int index) async {
    final item = cartItems[index];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus item?"),
          content: const Text(
            "Apakah kamu yakin ingin menghapus item ini dari cart?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await cartDatasource.deleteCart(item.cartId);

      setState(() {
        cartItems.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Item dihapus dari cart")));
    }
  }

  /// TOTAL HARGA
  double get totalPrice {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// FORMAT RUPIAH
  String rupiah(num number) {
    return "Rp${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  /// CHECKOUT FUNCTION
  Future<void> handleCheckout() async {
    final authUser = supabase.auth.currentUser;
    final String userId =
        authUser?.id ?? "00000000-0000-0000-0000-000000000000";

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Keranjang masih kosong")));
      return;
    }

    setState(() => checkoutLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      setState(() => checkoutLoading = false);
      return;
    }

    final items = cartItems.map((item) {
      return {
        "menu_topping_id": item.menuToppingId,
        "quantity": item.quantity,
        "price": item.price,
      };
    }).toList();

    final request = CreateOrderRequest(userId: userId, items: items);

    final datasource = OrderDatasource(Supabase.instance.client);

    try {
      await datasource.createOrder(request);

      final cartIds = cartItems.map((c) => c.cartId).toList();
      await cartDatasource.markCartAsPurchased(cartIds);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Order berhasil dibuat")));

      /// Option: hapus isi cart setelah checkout
      setState(() {
        cartItems.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Checkout gagal: $e")));
    } finally {
      setState(() => checkoutLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Cart",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/order-status'),
                          child: Image.asset(
                            'assets/images/orderhistory.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < cartItems.length; i++)
                      CartItemWidget(
                        item: cartItems[i],
                        onAdd: () {
                          setState(() => cartItems[i].quantity++);
                        },
                        onRemove: () {
                          if (cartItems[i].quantity > 1) {
                            setState(() {
                              cartItems[i].quantity--;
                            });
                          } else {
                            _confirmDeleteCart(i);
                          }
                        },
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// CHECKOUT BUTTON
            GestureDetector(
              onTap: checkoutLoading ? null : handleCheckout,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                height: 55,
                decoration: BoxDecoration(
                  color: checkoutLoading
                      ? Colors.brown.shade200
                      : const Color(0xFF4A2B10),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      checkoutLoading ? "Processing..." : "Check Out",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    Text(
                      rupiah(totalPrice),
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
            Container(),
          ],
        ),
      ),
    );
  }
}

/// ITEM CARD
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function() onAdd;
  final Function() onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp${item.price.toInt()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// BUTTONS
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemove,
              ),
              Text(
                item.quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
