import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../models/login_request.dart';
import '../models/signup_request.dart';

class AuthDataSource {
  final SupabaseClient supabase;

  AuthDataSource(this.supabase);

  // ============================
  // LOGIN
  // ============================
  Future<UserEntity> login(LoginRequest request) async {
    final res = await supabase.auth.signInWithPassword(
      email: request.email,
      password: request.password,
    );

    final user = res.user;
    if (user == null) throw Exception("Login gagal");

    final profile = await supabase
        .from("users")
        .select()
        .eq("email", user.email!)
        .maybeSingle();

    return UserEntity(
      id: int.tryParse(user.id) ?? 0,
      email: user.email ?? "",
      username: profile?["username"] ?? "",
      fullname: profile?["fullname"] ?? "",
      phoneNumber: profile?["phone_number"] ?? "",
      password: "",
      role: profile?["role"] ?? "",
    );
  }

  // ============================
  // SIGN UP
  // ============================
  Future<UserEntity> signUp(SignUpRequest request) async {
    // 1. Signup Supabase Auth
    final res = await supabase.auth.signUp(
      email: request.email,
      password: request.password,
    );

    final user = res.user;
    final createdUser = user ?? res.session?.user;
    if (createdUser == null) {
      throw Exception("Akun dengan email ini sudah ada");
    }

    // 2. Insert ke tabel users
    final inserted = await supabase.from("users").insert({
      "id": createdUser.id, // ← UUID dari Auth
      "email": request.email,
      "username": request.username,
      "fullname": request.fullname,
      "phone_number": request.phoneNumber,
      "password": request.password,
      "role": "user",
    });

    return UserEntity(
      id: inserted.id,
      email: inserted.email,
      username: inserted.username,
      fullname: inserted.fullname,
      phoneNumber: inserted.phoneNumber,
      password: inserted.password,
      role: "user",
    );
  }
}
