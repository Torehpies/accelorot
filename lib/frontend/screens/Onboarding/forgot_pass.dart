import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../ui/core/themes/app_theme.dart';
import '../../../routes/route_path.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPassScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  // Animation controllers
  late final AnimationController _blobController;
  late final AnimationController _cloudController;
  late final AnimationController _floatingController;
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _blobController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    // Wave animation removed - static waves only
  }

  @override
  void dispose() {
    _blobController.dispose();
    _cloudController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      final email = _emailController.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      context.go(RoutePath.resetEmailSent.path, extra: {'email': email});
    } on FirebaseAuthException catch (e) {
      showSnackbar(
        context,
        e.message ?? 'Failed to send reset email',
        isError: true,
      );
    } catch (e) {
      showSnackbar(context, 'An unexpected error occurred', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    final email = v.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFDCEDC8),
                    Color(0xFFC5E1A5),
                  ],
                ),
              ),
            ),
          ),

          // Animated decorative blobs - CHANGED TO LIGHT BLUE
          Positioned(
            top: -80,
            right: -80,
            child: _AnimatedDecorativeBlob(
              animation: _blobController,
              size: 300,
              color: const Color(0xFFADD8E6).withValues(alpha: 0.2),
              offset: 0,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _AnimatedDecorativeBlob(
              animation: _blobController,
              size: 350,
              color: const Color(0xFFADD8E6).withValues(alpha: 0.15),
              offset: 0.5,
            ),
          ),

          // Floating clouds - CHANGED TO LIGHT BLUE
          Positioned(
            top: 60,
            left: -40,
            child: _FloatingCloud(
              animation: _cloudController,
              size: 100,
              color: const Color(0xFFADD8E6).withValues(alpha: 0.8),
              offset: 0.0,
            ),
          ),
          Positioned(
            top: screenHeight * 0.3,
            right: -60,
            child: _FloatingCloud(
              animation: _cloudController,
              size: 140,
              color: const Color(0xFFADD8E6).withValues(alpha: 0.85),
              offset: 0.3,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.2,
            left: 40,
            child: _FloatingCloud(
              animation: _cloudController,
              size: 90,
              color: const Color(0xFFADD8E6).withValues(alpha: 0.8),
              offset: 0.6,
            ),
          ),

          // Floating leaves
          Positioned(
            top: 100,
            left: 40,
            child: _FloatingLeaf(
              animation: _floatingController,
              rotationAnimation: _rotationController,
              size: 30,
              offset: 0,
            ),
          ),
          Positioned(
            bottom: 200,
            right: 60,
            child: _FloatingLeaf(
              animation: _floatingController,
              rotationAnimation: _rotationController,
              size: 40,
              offset: 0.5,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: 100,
            child: _FloatingLeaf(
              animation: _floatingController,
              rotationAnimation: _rotationController,
              size: 25,
              offset: 0.3,
            ),
          ),
          Positioned(
            top: screenHeight * 0.6,
            left: 80,
            child: _FloatingLeaf(
              animation: _floatingController,
              rotationAnimation: _rotationController,
              size: 35,
              offset: 0.7,
            ),
          ),

          // Compost bins
          Positioned(
            bottom: 40,
            left: 30,
            child: _FloatingCompostBin(
              animation: _floatingController,
              size: 60,
              offset: 0.2,
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            right: 40,
            child: _FloatingCompostBin(
              animation: _floatingController,
              size: 50,
              offset: 0.8,
            ),
          ),

          // Trees
          Positioned(
            bottom: 60,
            right: screenWidth * 0.15,
            child: _FloatingTree(
              animation: _scaleController,
              size: 80,
              offset: 0.1,
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: 60,
            child: _FloatingTree(
              animation: _scaleController,
              size: 70,
              offset: 0.6,
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWideScreen ? 32 : 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: isWideScreen ? 8 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWideScreen ? 40 : 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Center(
                              child: SvgPicture.asset(
                                'assets/images/Accelorot_logo.svg',
                                width: isWideScreen ? 80 : 70,
                                height: isWideScreen ? 80 : 70,
                              ),
                            ),
                            SizedBox(height: isWideScreen ? 20 : 16),

                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: isWideScreen ? 26 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Enter the email associated with your account. We will send a password reset link to this email.',
                              style: TextStyle(fontSize: 16, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isWideScreen ? 32 : 24),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: isWideScreen ? 32 : 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendResetEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isWideScreen ? 18 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Send Reset Email',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Decorative Blob
class _AnimatedDecorativeBlob extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final Color color;
  final double offset;

  const _AnimatedDecorativeBlob({
    required this.animation,
    required this.size,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale =
            1.0 + (math.sin((animation.value + offset) * math.pi * 2) * 0.15);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      },
    );
  }
}

// Floating Leaf
class _FloatingLeaf extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> rotationAnimation;
  final double size;
  final double offset;

  const _FloatingLeaf({
    required this.animation,
    required this.rotationAnimation,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, rotationAnimation]),
      builder: (context, child) {
        final floatY = math.sin((animation.value + offset) * math.pi * 2) * 20;
        final floatX = math.cos((animation.value + offset) * math.pi * 2) * 10;
        final rotation = rotationAnimation.value * math.pi * 2;
        return Transform.translate(
          offset: Offset(floatX, floatY),
          child: Transform.rotate(
            angle: rotation,
            child: Icon(
              Icons.eco,
              size: size,
              color: AppColors.green100.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}

// Floating Cloud
class _FloatingCloud extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final Color color;
  final double offset;

  const _FloatingCloud({
    required this.animation,
    required this.size,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final floatY = math.sin((animation.value + offset) * math.pi * 2) * 8;
        final driftX = math.cos((animation.value + offset) * math.pi * 2) * 5;
        final scale =
            0.95 +
            (math.sin((animation.value + offset * 2) * math.pi * 2) * 0.05);
        return Transform.translate(
          offset: Offset(driftX, floatY),
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.5),
              child: CustomPaint(
                size: Size(size, size * 0.6),
                painter: _CloudPainter(color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final Color color;
  _CloudPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.height * 0.45;

    canvas.drawCircle(Offset(centerX * 0.6, centerY), radius, paint);
    canvas.drawCircle(Offset(centerX, centerY * 0.8), radius * 1.2, paint);
    canvas.drawCircle(Offset(centerX * 1.4, centerY), radius, paint);
    canvas.drawCircle(
      Offset(centerX * 0.8, centerY * 1.3),
      radius * 0.9,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX * 1.2, centerY * 1.3),
      radius * 0.9,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating Compost Bin
class _FloatingCompostBin extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final double offset;

  const _FloatingCompostBin({
    required this.animation,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final floatY = math.sin((animation.value + offset) * math.pi * 2) * 10;
        final scale =
            0.95 + (math.sin((animation.value + offset) * math.pi * 2) * 0.05);
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size(size, size * 1.2),
              painter: _CompostBinPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _CompostBinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final binPaint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..style = PaintingStyle.fill;

    final lidPaint = Paint()
      ..color = const Color(0xFF6B5235)
      ..style = PaintingStyle.fill;

    // Bin body with rounded corners
    final binPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.1,
            size.height * 0.2,
            size.width * 0.8,
            size.height * 0.7,
          ),
          Radius.circular(size.width * 0.1),
        ),
      );
    canvas.drawPath(binPath, binPaint);

    // Lid with rounded corners
    final lidPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.25),
          Radius.circular(size.width * 0.15),
        ),
      );
    canvas.drawPath(lidPath, lidPaint);

    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFF6B5235)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.1),
        width: size.width * 0.3,
        height: size.height * 0.15,
      ),
      math.pi,
      math.pi,
      false,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating Tree
class _FloatingTree extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final double offset;

  const _FloatingTree({
    required this.animation,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale =
            1.0 + (math.sin((animation.value + offset) * math.pi * 2) * 0.08);
        final sway = math.sin((animation.value + offset) * math.pi * 2) * 0.05;
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: sway,
            child: CustomPaint(
              size: Size(size, size * 1.5),
              painter: _TreePainter(),
            ),
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Trunk with rounded corners
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..style = PaintingStyle.fill;

    final trunkPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.4,
            size.height * 0.5,
            size.width * 0.2,
            size.height * 0.5,
          ),
          Radius.circular(size.width * 0.05),
        ),
      );
    canvas.drawPath(trunkPath, trunkPaint);

    // Foliage (rounded circles) - CHANGED TO LIGHT BLUE
    final foliagePaint = Paint()
      ..color = const Color(0xFFADD8E6).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.35,
      foliagePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.35),
      size.width * 0.25,
      foliagePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.35),
      size.width * 0.25,
      foliagePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

