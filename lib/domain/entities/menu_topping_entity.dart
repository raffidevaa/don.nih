class MenuToppingEntity {
  final int id;
  final int menuId;
  final List<int> toppingIds;

  MenuToppingEntity({
    required this.id,
    required this.menuId,
    required this.toppingIds,
  });
}
