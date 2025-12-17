    import 'package:supabase_flutter/supabase_flutter.dart';
    import '../models/create_order_request.dart';
    import '../models/create_order_response.dart';
    import '../../domain/entities/order_entity.dart';
    import '../models/order_response.dart';

class OrderDatasource {
  final SupabaseClient supabase;

  OrderDatasource(this.supabase);

  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    // Insert order ke tabel `orders`
    final insertedOrder = await supabase
        .from('orders')
        .insert({
          'user_id': request.userId,
          'order_status': 'WAITING',
          'payment_status': 'PENDING',
          'midtrans_order_id': 'NULL', // to be updated later
          'net_income': 0,
          'payment_link': 'NULL', // to be updated later
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String()
        })
        .select()
        .single();

    final orderId = insertedOrder['id'] as int;

    double total = 0;

    // Insert order detail untuk setiap item
    for (var item in request.items) {
      await supabase.from('order_details').insert({
        'order_id': orderId,
        'menu_topping_id': item['menu_topping_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });

      total += item['price'] * item['quantity'];
    }

    // Update total income table `orders`
    await supabase
        .from('orders')
        .update({'net_income': total})
        .eq('id', orderId);

    final updatedOrder = await supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .single();

    final entity = OrderEntity(
      id: orderId,
      userId: updatedOrder['user_id'],
      orderStatus: updatedOrder['order_status'],
      paymentStatus: updatedOrder['payment_status'],
      midtransOrderId: updatedOrder['midtrans_order_id'],
      netIncome: updatedOrder['net_income']?.toDouble() ?? 0.0,
      paymentLink: updatedOrder['payment_link'],
      createdAt: DateTime.parse(updatedOrder['created_at']),
      updatedAt: DateTime.parse(updatedOrder['updated_at']),
    );

    return CreateOrderResponse(
      id: entity.id,
      userId: entity.userId,
      orderStatus: entity.orderStatus,
      paymentStatus: entity.paymentStatus,
      midtransOrderId: entity.midtransOrderId,
      netIncome: entity.netIncome,
      paymentLink: entity.paymentLink,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

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

  Future<Map<String, dynamic>> getOrderStatusByOrderId(int orderId) async {
    final response = await supabase
        .from('orders')
        .select('order_status, created_at, updated_at')
        .eq('id', orderId)
        .single();

    return response;
  }

}
