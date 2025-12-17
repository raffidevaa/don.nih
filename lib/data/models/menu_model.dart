import '../../domain/entities/menu_entity.dart';

class MenuModel {
  final int id;
  final String name;
  final double price;
  final int? topping;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    this.topping,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      topping: json['topping'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      if (topping != null) 'topping': topping,
    };
  }

  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      name: name,
      price: price,
      topping: topping,
    );
  }

  factory MenuModel.fromEntity(MenuEntity entity) {
    return MenuModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      topping: entity.topping,
    );
  }
}
