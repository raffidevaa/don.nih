import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          // TOP SHAPE
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(height: 100, color: Colors.brown.shade200),
          ),

          // BOTTOM SHAPE
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(height: 100, color: Colors.brown.shade200),
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
                  const SizedBox(height: 30),

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
                  const SizedBox(height: 12),

                  // USERNAME
                  _buildInputField(
                    controller: _username,
                    label: "Username",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your username" : null,
                  ),
                  const SizedBox(height: 12),

                  // PASSWORD
                  _buildInputField(
                    controller: _password,
                    label: "Password",
                    obscure: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your password" : null,
                  ),
                  const SizedBox(height: 12),

                  // FULL NAME
                  _buildInputField(
                    controller: _fullname,
                    label: "Full Name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your full name" : null,
                  ),
                  const SizedBox(height: 12),

                  // PHONE NUMBER
                  _buildInputField(
                    controller: _phone,
                    label: "Phone Number",
                    validator: (v) => v == null || v.isEmpty
                        ? "Enter your phone number"
                        : null,
                  ),

                  const SizedBox(height: 25),

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

                  const SizedBox(height: 30),

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

// ============================================================
// CLIPPERS (unchanged, hanya dirapikan sedikit)
// ============================================================
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width / 2, -20, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
