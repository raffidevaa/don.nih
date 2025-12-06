import '../../domain/entities/order_entity.dart';

class OrderModel {
  final int id;
  final String userId;
  final int cartId;
  final int quantity;
  final String orderStatus;
  final String paymentStatus;
  final String midtransOrderId;
  final double netIncome;
  final String paymentLink;

  OrderModel({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.quantity,
    required this.orderStatus,
    required this.paymentStatus,
    required this.midtransOrderId,
    required this.netIncome,
    required this.paymentLink,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      cartId: json['cart_id'],
      quantity: json['quantity'],
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      midtransOrderId: json['midtrans_order_id'],
      netIncome: (json['net_income'] as num).toDouble(),
      paymentLink: json['payment_link'],
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      cartId: cartId,
      quantity: quantity,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      midtransOrderId: midtransOrderId,
      netIncome: netIncome,
      paymentLink: paymentLink,
    );
  }
}
