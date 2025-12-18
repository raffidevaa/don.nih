import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/topping_model.dart';

class ToppingDataSource {
  final SupabaseClient client;
  ToppingDataSource(this.client);

  /// GET ALL toppings (kecualikan ID = 1 misalnya)
  Future<List<ToppingModel>> getAllToppings() async {
    final response = await client
        .from('toppings')
        .select()
        .neq('id', 1); // ❗ Hardcode pengecualian satu topping OK

    return (response as List<dynamic>)
        .map((e) => ToppingModel.fromMap(e))
        .toList();
  }

  /// CREATE new topping
  Future<ToppingModel> createTopping(String name, int price) async {
    final response = await client
        .from('toppings')
        .insert({
          'name': name,
          'price': price,
        })
        .select()
        .single();

    return ToppingModel.fromMap(response);
  }

  /// UPDATE topping
  Future<void> updateTopping(int id, String name, int price) async {
    await client
        .from('toppings')
        .update({
          'name': name,
          'price': price,
        })
        .eq('id', id);
  }

  /// DELETE topping
  Future<void> deleteTopping(int id) async {
    await client
        .from('toppings')
        .delete()
        .eq('id', id);
  }
}
