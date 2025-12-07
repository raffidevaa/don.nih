class CartItemResponse {
  final int cartId;
  final String menuName;
  final String menuImage;
  final List<String> toppings;
  final double baseTotal;
  final int menuToppingId;

  CartItemResponse({
    required this.cartId,
    required this.menuName,
    required this.menuImage,
    required this.toppings,
    required this.baseTotal,
    required this.menuToppingId,
  });
}
