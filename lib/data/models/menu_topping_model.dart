class MenuToppingModel {
  final int id;
  final int menuId;
  final List<int> toppings;

  MenuToppingModel({
    required this.id,
    required this.menuId,
    required this.toppings,
  });

  factory MenuToppingModel.fromJson(Map<String, dynamic> json) {
    return MenuToppingModel(
      id: json["id"],
      menuId: json["menu_id"],
      toppings: (json["toppings"] as String)
          .split(",")
          .map((e) => int.parse(e))
          .toList(),
    );
  }
}
