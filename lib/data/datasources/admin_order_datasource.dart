import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_response.dart';

class AdminOrderDatasource {
  final SupabaseClient supabase;

  AdminOrderDatasource(this.supabase);

  /// Get ALL orders (for admin) - tidak difilter by user_id
  Future<List<OrderEntity>> getAllOrders() async {
    final response = await supabase
        .from('orders')
        .select()
        .order('id', ascending: false);

    if (response.isEmpty) return [];

    return response
        .map((json) => OrderModel.fromJson(json).toEntity())
        .toList();
  }

  /// Update order status (for admin)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    await supabase
        .from('orders')
        .update({
          'order_status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  /// Get single order by ID (for admin detail page)
  Future<OrderEntity?> getOrderById(int orderId) async {
    final response = await supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) return null;

    return OrderModel.fromJson(response).toEntity();
  }
}
