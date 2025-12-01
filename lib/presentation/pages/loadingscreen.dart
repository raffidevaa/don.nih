import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _steamController;

  @override
  void initState() {
    super.initState();

    _steamController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Auto navigate to LoginPage
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _steamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF3d2817), const Color(0xFF5c3d2e)],
          ),
        ),
        child: Stack(
          children: [
            // Background Image (ganti dengan foto kamu)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://via.placeholder.com/1920x1080?text=Your+Image+Here',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
            ),
            // Dark Overlay
            Container(color: Colors.black.withOpacity(0.7)),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      // KEDAI Text
                      const Text(
                        'KEDAI',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 3,
                          color: Color(0xFFd4af8a),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Cup Icon with Steam
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Steam Lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SteamLine(
                                controller: _steamController,
                                delayFraction: 0.0,
                              ),
                              const SizedBox(width: 15),
                              SteamLine(
                                controller: _steamController,
                                delayFraction: 0.3,
                              ),
                              const SizedBox(width: 15),
                              SteamLine(
                                controller: _steamController,
                                delayFraction: 0.6,
                              ),
                            ],
                          ),
                          // Cup
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Image.asset(
                              'assets/images/LogoDonnih.png',
                              height: 120,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  // Brand Name
                  const Text(
                    'DON.NIH!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk Steam Line
class SteamLine extends StatelessWidget {
  final AnimationController controller;
  final double delayFraction;

  const SteamLine({
    super.key,
    required this.controller,
    required this.delayFraction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = (controller.value + delayFraction) % 1.0;
        double opacity = progress < 0.5 ? progress * 2 : 2 - (progress * 2);

        return Transform.translate(
          offset: Offset(0, -progress * 25),
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af8a),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget untuk Spinner Dot
class SpinnerDot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const SpinnerDot({super.key, required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = (controller.value + delay / 1.4) % 1.0;
        double scale = progress < 0.4
            ? progress / 0.4
            : 1 - (progress - 0.4) / 0.6;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFFd4af8a),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter untuk Cup
class CupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFd4af8a)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Cup body
    path.moveTo(size.width * 0.3, size.height * 0.35);
    path.lineTo(size.width * 0.35, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.45,
      size.height * 0.75,
    );
    path.lineTo(size.width * 0.55, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.75,
      size.width * 0.65,
      size.height * 0.65,
    );
    path.lineTo(size.width * 0.7, size.height * 0.35);

    canvas.drawPath(path, paint);

    // Cup handle
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.7, size.height * 0.45);
    handlePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width * 0.85,
      size.height * 0.55,
    );
    handlePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.65,
      size.width * 0.7,
      size.height * 0.65,
    );

    canvas.drawPath(handlePath, paint);

    // Saucer
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.8),
        width: size.width * 0.56,
        height: size.height * 0.12,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CupPainter oldDelegate) => false;
}
