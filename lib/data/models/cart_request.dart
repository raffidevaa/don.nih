class CartRequest {
  final String userId;
  final int menuId;
  final List<int> toppings;

  CartRequest({
    required this.userId,
    required this.menuId,
    required this.toppings,
  });

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "menu_id": menuId,
    "toppings": toppings,
  };
}
