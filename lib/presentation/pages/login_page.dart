import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // TOP CURVE
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(height: 130, color: Colors.brown.shade200),
          ),

          // BOTTOM CURVE
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(height: 130, color: Colors.brown.shade200),
            ),
          ),

          // MAIN FORM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 150),

                  const Center(
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Center(
                    child: Text(
                      'Login to continue your journey',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // USERNAME
                  SizedBox(
                    height: 55,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 180, 170, 164),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email required';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  SizedBox(
                    height: 55,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 180, 170, 164),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password required';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN BUTTON
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 207, 114, 68),
                          Colors.brown.shade600,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                try {
                                  // 🔥 Login ke Supabase
                                  final response = await Supabase
                                      .instance
                                      .client
                                      .auth
                                      .signInWithPassword(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                      );

                                  if (response.user == null) {
                                    throw Exception("Login gagal");
                                  }

                                  // 🔥 Ambil profile dari tabel users
                                  final profile = await Supabase.instance.client
                                      .from("users")
                                      .select()
                                      .eq("id", response.user!.id)
                                      .maybeSingle();

                                  if (profile == null) {
                                    throw Exception(
                                      "Data profil tidak ditemukan di tabel users",
                                    );
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Welcome ${profile["fullname"]}!",
                                      ),
                                    ),
                                  );
                                  if (profile["role"] == "admin") {
                                    // ⬇️ Navigate ke admin home
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/admin/home',
                                    );
                                    return;
                                  } else {
                                    // ⬇️ Navigate ke user home
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SIGN UP REDIRECT
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.brown, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Same clippers you already use
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width - 70,
      size.height - 70,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height - 70,
      size.width,
      size.height - 5,
    );
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height - 70,
      size.width,
      size.height - 5,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width - 70,
      size.height - 70,
    );
    path.lineTo(size.height * 0.3, size.width);
    path.lineTo(0, size.width);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}
