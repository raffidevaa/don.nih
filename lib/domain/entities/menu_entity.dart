class MenuEntity {
  final int id;
  final String name;
  final double price;
  final int? topping; // foreign key → toppings.id (nullable)
  final String? img;

  MenuEntity({
    required this.id,
    required this.name,
    required this.price,
    this.topping,
    this.img,
  });
}
