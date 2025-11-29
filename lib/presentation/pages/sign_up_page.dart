import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Desain melengkung dengan warna coklat di bagian atas
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              height: 100,
              color: Colors.brown.shade200, // Warna coklat latar belakang
            ),
          ),
          
          // Desain melengkung dengan warna coklat di bagian bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                height: 100,
                color: Colors.brown.shade200, // Warna coklat latar belakang bawah
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
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.brown), // Mengubah warna menjadi coklat
                    ),
                  ),
                  const SizedBox(height: 5), 
                  const Center(
                    child: Text(
                      'Create your account.',
                      style: TextStyle(fontSize: 18, color: Colors.grey), // Mengubah warna menjadi abu-abu
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Lebar 80% dari layar
                    height: 50, // Tinggi input field
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2), // Warna emas saat tidak fokus
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Lebar 80% dari layar
                    height: 50, // Tinggi input field
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2), // Warna emas saat tidak fokus
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Full Name Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Lebar 80% dari layar
                    height: 50, // Tinggi input field
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2), // Warna emas saat tidak fokus
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Phone Number Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Lebar 80% dari layar
                    height: 50, // Tinggi input field
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2), // Warna emas saat tidak fokus
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Button (with gradient)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 207, 114, 68), Colors.brown.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          // Simulating form submission process
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign Up Success')),
                            );
                          });
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white), // Set the text color to white
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Transparent to show gradient
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Link TextButton
                  TextButton(
                    onPressed: () {
                      // Navigate to Login Page
                    },
                    child: const Text(
                      "Already have an account? Login here.",
                      style: TextStyle(
                        color: Colors.brown, // Set the color to brown
                      ),
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

// Custom clipper untuk membuat desain melengkung di bagian atas
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);  // Mulai dari titik kiri atas
    path.lineTo(0, size.height * 0.2);  // Menurunkan ke bawah sebelum kurva
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width - 70, size.height - 70);  // Membuat kurva di bagian bawah
    path.quadraticBezierTo(size.width * 0.4, size.height - 70, size.width, size.height - 5);
    path.lineTo(size.width, size.height * 0.3); // Draw to the bottom-right corner
    path.lineTo(size.width, 0);  // Kembali ke titik kanan atas
    path.close();  // Menutup path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Custom clipper untuk membuat desain melengkung di bagian bawah
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);  // Mulai dari titik kiri atas
    path.lineTo(0, size.height * 0.2);  // Menurunkan ke bawah sebelum kurva
    path.quadraticBezierTo(size.width * 0.4, size.height - 70, size.width, size.height - 5);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width - 70, size.height - 70);  // Membuat kurva di bagian bawah
    path.lineTo(size.height * 0.3, size.width); // Draw to the bottom-right corner
    path.lineTo(0, size.width);  // Kembali ke titik kanan atas
    path.close();  // Menutup path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
