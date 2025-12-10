class OrderDetailModel {
  final int id;
  final int orderId;
  final int quantity;
  final double price;
  final int menuToppingId;
  final int menuId;
  final String? productName;

  OrderDetailModel({
    required this.id,
    required this.orderId,
    required this.quantity,
    required this.price,
    required this.menuToppingId,
    required this.menuId,
    required this.productName,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final mt = json["menu_toppings"] as Map<String, dynamic>?;
    final menu = mt?["menus"] as Map<String, dynamic>?;

    return OrderDetailModel(
      id: json["id"] as int,
      orderId: json["order_id"] as int,
      quantity: json["quantity"] as int,
      price: (json["price"] as num).toDouble(),

      menuToppingId: mt?["id"] as int? ?? 0,
      menuId: mt?["menu_id"] as int? ?? 0,

      productName: menu?["name"] as String? ?? "",
    );
  }
}
