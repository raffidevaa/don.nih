import '../../domain/entities/menu_entity.dart';

class MenuModel {
  final int id;
  final String name;
  final String size;
  final String temperature;
  final double price;
  final int? topping; // nullable karena bisa null di database

  MenuModel({
    required this.id,
    required this.name,
    required this.size,
    required this.temperature,
    required this.price,
    this.topping,
  });

  /// Factory untuk parsing dari JSON (response Supabase)
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      size: json['size'] as String? ?? '',
      temperature: json['temperature'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      topping: json['topping'] as int?,
    );
  }

  /// Convert ke JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'temperature': temperature,
      'price': price,
      if (topping != null) 'topping': topping,
    };
  }

  /// Convert ke Entity
  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      name: name,
      size: size,
      temperature: temperature,
      price: price,
      topping: topping,
    );
  }

  /// Create from Entity
  factory MenuModel.fromEntity(MenuEntity entity) {
    return MenuModel(
      id: entity.id,
      name: entity.name,
      size: entity.size,
      temperature: entity.temperature,
      price: entity.price,
      topping: entity.topping,
    );
  }
}
