class CartEntity {
  final int id;
  final int userId;
  final List<int> menuToppingId;
  final double total;
  final bool isPurchased;

  CartEntity({
    required this.id,
    required this.userId,
    required this.menuToppingId,
    required this.total,
    required this.isPurchased,
  });
}
