import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              height: 100,
              color: Colors.brown.shade200, 
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                height: 100,
                color: Colors.brown.shade200, 
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 155),
                  const Center(
                    child: Text(
                      'Welcome back!',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                  ),
                  const SizedBox(height: 5), 
                  const Center(
                    child: Text(
                      'Login to your account.',
                      style: TextStyle(fontSize: 18, color: Colors.grey), 
                    ),
                  ),
                  const SizedBox(height: 30),

                
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, 
                    height: 50, 
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2),
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

           
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, 
                    height: 50, 
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 180, 170, 164), width: 2), 
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
                              'Login',
                              style: TextStyle(color: Colors.white), 
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: const Text(
                      "Don't have an account? Sign Up here.",
                      style: TextStyle(
                        color: Colors.brown, 
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


class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0); 
    path.lineTo(0, size.height * 0.2); 
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width - 70, size.height - 70); 
    path.quadraticBezierTo(size.width * 0.4, size.height - 70, size.width, size.height - 5);
    path.lineTo(size.width, size.height * 0.3); 
    path.lineTo(size.width, 0);  
    path.close();  

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}


class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);  
    path.lineTo(0, size.height * 0.2);  
    path.quadraticBezierTo(size.width * 0.4, size.height - 70, size.width, size.height - 5);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width - 70, size.height - 70);  
    path.lineTo(size.height * 0.3, size.width); 
    path.lineTo(0, size.width);  
    path.close();  

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
