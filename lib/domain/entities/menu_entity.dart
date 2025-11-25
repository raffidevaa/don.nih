class MenuEntity {
  final int id;
  final String name;
  final String size;
  final String temperature;
  final double price;
  final int topping; // foreign key → toppings.id

  MenuEntity({
    required this.id,
    required this.name,
    required this.size,
    required this.temperature,
    required this.price,
    required this.topping,
  });
}
