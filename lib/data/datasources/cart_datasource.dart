import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_request.dart';
import '../models/cart_response.dart';
import '../models/cart_item_response.dart';
import 'storage_datasource.dart';

class CartDatasource {
  final supabase = Supabase.instance.client;
  final StorageDatasource storage = StorageDatasource();

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

  Future<List<CartItemResponse>> getCartItems(String userId) async {
    final carts = await supabase
        .from('carts')
        .select('id, menu_topping_id, total')
        .eq('user_id', userId)
        .eq('is_purchased', false);

    List<CartItemResponse> results = [];

    for (var c in carts) {
      final mt = await supabase
          .from('menu_toppings')
          .select('menu_id, toppings')
          .eq('id', c['menu_topping_id'])
          .single();

      final menu = await supabase
          .from('menus')
          .select('id, name, img, price')
          .eq('id', mt['menu_id'])
          .single();

      List<int> toppingIds = mt['toppings']
          .toString()
          .split(',')
          .map((e) => int.parse(e))
          .toList();

      final toppingRows = await supabase
          .from('toppings')
          .select()
          .inFilter('id', toppingIds);

      final toppingNames = toppingRows
          .map((e) => e['name'].toString())
          .toList();

      final imageUrl = storage.getImageUrl(
        id: menu['id'].toString(),
        folderName: "menu",
        fileType: "png",
      );

      results.add(
        CartItemResponse(
          cartId: c['id'],
          menuName: menu['name'],
          menuImage: imageUrl,
          toppings: toppingNames,
          baseTotal: (c['total'] as num).toDouble(),
          menuToppingId: c['menu_topping_id'],
        ),
      );
    }

    return results;
  }

  Future<void> markCartAsPurchased(List<int> cartIds) async {
    if (cartIds.isEmpty) return;

    await supabase
        .from('carts')
        .update({'is_purchased': true})
        .inFilter('id', cartIds);
  }
}
