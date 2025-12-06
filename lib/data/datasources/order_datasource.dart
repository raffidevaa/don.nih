import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_response.dart';
import '../../domain/entities/order_entity.dart';

class OrderDataSource {
  final supabase = Supabase.instance.client;

  Future<List<OrderEntity>> getOrdersByUserId(String userId) async {
    final response = await supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    if (response.isEmpty) return [];

    return response
        .map((json) => OrderModel.fromJson(json).toEntity())
        .toList();
  }

}
