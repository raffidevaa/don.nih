class CartEntity {
  final int id;
  final int userId;
  final int menuToppingId;
  final double total;
  final int quantity;
  final bool isPurchased;

  CartEntity({
    required this.id,
    required this.userId,
    required this.menuToppingId,
    required this.total,
    required this.quantity,
    required this.isPurchased,
  });
}
