import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_detail_response.dart';
import '../../domain/entities/order_detail_entity.dart';

class OrderDetailDatasource {
  final SupabaseClient supabase;

  OrderDetailDatasource(this.supabase);

  Future<List<Map<String, dynamic>>>  getOrderDetailByOrderId(int orderId) async {
    final response = await supabase
        .from('order_details')
        .select('''
      id,
      order_id,
      quantity,
      price,
      menu_toppings (
        id,
        menu_id,
        menus (
          id,
          name
        )
      )
    ''')
        .eq('order_id', orderId);


    if (response.isEmpty) return [];

    return response;

  }

}