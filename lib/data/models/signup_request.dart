class SignUpRequest {
  final String email;
  final String password;
  final String username;
  final String fullname;
  final String phoneNumber;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.fullname,
    required this.phoneNumber,
  });
}
