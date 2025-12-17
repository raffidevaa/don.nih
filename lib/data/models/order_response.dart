import '../../domain/entities/order_entity.dart';

class OrderModel {
  final int id;
  final String userId;
  final String orderStatus;
  final String paymentStatus;
  final String midtransOrderId;
  final double netIncome;
  final String paymentLink;
  final DateTime createdAt;
  DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.midtransOrderId,
    required this.netIncome,
    required this.paymentLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      midtransOrderId: json['midtrans_order_id'],
      netIncome: (json['net_income'] as num).toDouble(),
      paymentLink: json['payment_link'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      midtransOrderId: midtransOrderId,
      netIncome: netIncome,
      paymentLink: paymentLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
