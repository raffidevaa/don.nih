import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_request.dart';
import '../models/cart_response.dart';

class CartDatasource {
  final supabase = Supabase.instance.client;

  Future<double> _calculateTotal(int menuId, List<int> toppingIds) async {
    // Ambil menu price
    final menu = await supabase
        .from('menus')
        .select('price')
        .eq('id', menuId)
        .single();

    double menuPrice = (menu['price'] as num).toDouble();

    // Ambil topping prices
    final toppings = await supabase
        .from('toppings')
        .select()
        .inFilter('id', toppingIds);

    double toppingTotal = toppings.fold(
      0.0,
      (sum, t) => sum + (t['price'] as num).toDouble(),
    );

    return menuPrice + toppingTotal;
  }

  Future<int> _insertMenuToppings(int menuId, List<int> toppingIds) async {
    final response = await supabase
        .from('menu_toppings')
        .insert({'menu_id': menuId, 'toppings': toppingIds.join(',')})
        .select('id')
        .single();

    return response['id'];
  }

  Future<CartResponse> addToCart(CartRequest request) async {
    final total = await _calculateTotal(request.menuId, request.toppings);

    final menuToppingId = await _insertMenuToppings(
      request.menuId,
      request.toppings,
    );

    final inserted = await supabase
        .from('carts')
        .insert({
          'user_id': request.userId,
          'menu_topping_id': menuToppingId,
          'total': total,
          'is_purchased': false,
        })
        .select()
        .single();

    return CartResponse.fromJson(inserted);
  }

  Future<void> deleteCart(int id) async {
    await supabase.from('carts').delete().eq('id', id);
  }
}
