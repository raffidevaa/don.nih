class UserEntity {
  final int id;
  final String username;
  final String fullname;
  final String email;
  final String password;
  final String phoneNumber;
  final String role;

  UserEntity({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });
}
