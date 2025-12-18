import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/models/signup_request.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _fullname = TextEditingController();
  final _phone = TextEditingController();

  bool _isLoading = false;

  // ============================================================
  // SIGN UP FUNCTION
  // ============================================================
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final datasource = AuthDataSource(Supabase.instance.client);

    try {
      final req = SignUpRequest(
        email: _email.text.trim(),
        password: _password.text.trim(),
        username: _username.text.trim(),
        fullname: _fullname.text.trim(),
        phoneNumber: _phone.text.trim(),
      );

      final user = await datasource.signUp(req);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Success. Welcome ${user.username}!")),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign Up Failed: $e")));
    }

    setState(() => _isLoading = false);
  }

  // ============================================================
  // BUILD INPUT FIELD
  // ============================================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 180, 170, 164),
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 90),
                  const Center(
                    child: Text(
                      'Welcome!',
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
                      'Create your account.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // EMAIL
                  _buildInputField(
                    controller: _email,
                    label: "Email",
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter your email";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                        return "Invalid email format";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // USERNAME
                  _buildInputField(
                    controller: _username,
                    label: "Username",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your username" : null,
                  ),
                  const SizedBox(height: 10),

                  // PASSWORD
                  _buildInputField(
                    controller: _password,
                    label: "Password",
                    obscure: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your password" : null,
                  ),
                  const SizedBox(height: 10),

                  // FULL NAME
                  _buildInputField(
                    controller: _fullname,
                    label: "Full Name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your full name" : null,
                  ),
                  const SizedBox(height: 10),

                  // PHONE NUMBER
                  _buildInputField(
                    controller: _phone,
                    label: "Phone Number",
                    validator: (v) => v == null || v.isEmpty
                        ? "Enter your phone number"
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // SIGN UP BUTTON
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 207, 114, 68),
                          Colors.brown.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login here.",
                      style: TextStyle(color: Colors.brown),
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