class OrderEntity {
  final int id;
  final int userId;
  final int cartId;
  final String orderStatus;
  final String paymentStatus;
  final String midtransOrderId;
  final double netIncome;
  final String paymentLink;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.midtransOrderId,
    required this.netIncome,
    required this.paymentLink,
  });
}
