class OrderDetailEntity {
  final int id;
  final int orderId;
  final int menuToppingId;
  final int quantity;
  final double price;

  OrderDetailEntity({
    required this.id,
    required this.orderId,
    required this.menuToppingId,
    required this.quantity,
    required this.price,
  });
}
