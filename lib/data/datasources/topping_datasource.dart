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
}
