class CreateOrderRequest {
  final String userId;
  final List<Map<String, dynamic>> items;

  CreateOrderRequest({required this.userId, required this.items});

  Map<String, dynamic> toJson() {
    return {"user_id": userId, "items": items};
  }
}
