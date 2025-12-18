import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 134,
              child: SvgPicture.string(
                '''<svg xmlns="http://www.w3.org/2000/svg" width="402" height="134" viewBox="0 0 402 134" fill="none">
                  <path d="M402 0L402 129C370.5 137 333.5 137.5 293.5 100C255.123 64.021 188.5 80.5 146.5 87C104.5 93.5 27 90 0 28V0H402Z" fill="#B29F91"/>
                </svg>''',
                fit: BoxFit.fill,
              ),
            ),
          ),

          // BOTTOM CURVE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 134,
              child: SvgPicture.string(
                '''<svg xmlns="http://www.w3.org/2000/svg" width="402" height="134" viewBox="0 0 402 134" fill="none">
                  <path d="M0 133.377L0.000488281 4.37683C31.5 -3.62317 68.5 -4.12317 108.5 33.3768C146.877 69.3558 213.5 52.8768 255.5 46.3768C297.5 39.8768 375 43.3768 402 105.377V133.377H0Z" fill="#B29F91"/>
                </svg>''',
                fit: BoxFit.fill,
              ),
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
                                  // Login ke Supabase
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

                                  // Ambil profile dari tabel users
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
                                    // Navigate ke user home
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