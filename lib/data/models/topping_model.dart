class ToppingModel {
  final int id;
  final String name;
  final int price;

  ToppingModel({required this.id, required this.name, required this.price});

  factory ToppingModel.fromMap(Map<String, dynamic> map) {
    return ToppingModel(id: map['id'], name: map['name'], price: map['price']);
  }
}
