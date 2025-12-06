class OrderEntity {
  final int id;
  final String userId;
  final int cartId;
  final int quantity;
  final String orderStatus;
  final String paymentStatus;
  final String midtransOrderId;
  final double netIncome;
  final String paymentLink;

  OrderEntity({
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
}
