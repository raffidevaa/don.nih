import '../../domain/entities/user_entity.dart';

class LoginResponse {
  final int status;
  final String message;
  final UserEntity data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final d = json["data"];

    return LoginResponse(
      status: json["status"],
      message: json["message"],
      data: UserEntity(
        id: d["id"].toString(),
        username: d["username"],
        fullname: d["fullname"],
        email: d["email"],
        password: "",
        phoneNumber: d["phone_number"],
        role: d["role"],
      ),
    );
  }
}
