class CartItemResponse {
  final int cartId;
  final String menuName;
  final String menuImage;
  final List<String> toppings;
  final double baseTotal;

  CartItemResponse({
    required this.cartId,
    required this.menuName,
    required this.menuImage,
    required this.toppings,
    required this.baseTotal,
  });
}
