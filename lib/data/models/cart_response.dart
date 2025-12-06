class CartResponse {
  final int id;
  final String userId;
  final int menuToppingId;
  final double total;
  final bool isPurchased;

  CartResponse({
    required this.id,
    required this.userId,
    required this.menuToppingId,
    required this.total,
    required this.isPurchased,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'],
      userId: json['user_id'],
      menuToppingId: json['menu_topping_id'],
      total: (json['total'] as num).toDouble(),
      isPurchased: json['is_purchased'] ?? false,
    );
  }
}
