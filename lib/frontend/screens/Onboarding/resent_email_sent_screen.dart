import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/core/themes/app_theme.dart';
import '../../../routes/route_path.dart';

class ResetEmailSentScreen extends StatefulWidget {
  final String email;

  const ResetEmailSentScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetEmailSentScreen> createState() => _ResetEmailSentScreenState();
}

class _ResetEmailSentScreenState extends State<ResetEmailSentScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _blobController;
  late final AnimationController _cloudController;
  late final AnimationController _floatingController;
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;
  late final AnimationController _waveController;
  late final AnimationController _successController;

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

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _cloudController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    _successController.dispose();
    super.dispose();
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





          // Floating email icons (celebrating success)
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.1,
            child: _FloatingEmailIcon(
              animation: _floatingController,
              size: 30,
              offset: 0.1,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: screenWidth * 0.1,
            child: _FloatingEmailIcon(
              animation: _floatingController,
              size: 25,
              offset: 0.4,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Success Icon with animation
                          Center(
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                parent: _successController,
                                curve: Curves.elasticOut,
                              ),
                              child: Container(
                                width: isWideScreen ? 100 : 80,
                                height: isWideScreen ? 100 : 80,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mark_email_read_outlined,
                                  size: isWideScreen ? 50 : 40,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isWideScreen ? 24 : 20),

                          // Title
                          FadeTransition(
                            opacity: _successController,
                            child: Text(
                              'Email Sent!',
                              style: TextStyle(
                                fontSize: isWideScreen ? 26 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Message
                          Text(
                            'A password reset link has been sent to',
                            style: TextStyle(
                              fontSize: isWideScreen ? 16 : 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Email address
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: isWideScreen ? 16 : 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Please check your inbox and follow the instructions to reset your password.',
                            style: TextStyle(
                              fontSize: isWideScreen ? 16 : 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isWideScreen ? 32 : 24),

                          // Info box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Didn\'t receive the email? Check your spam folder.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[900],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isWideScreen ? 32 : 24),

                          // Back to Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.go(RoutePath.signin.path);
                              },
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
                              child: const Text(
                                'Back to Sign In',
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
        final scale = 1.0 + (math.sin((animation.value + offset) * math.pi * 2) * 0.15);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
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
        final scale = 0.95 + (math.sin((animation.value + offset * 2) * math.pi * 2) * 0.05);
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
    canvas.drawCircle(Offset(centerX * 0.8, centerY * 1.3), radius * 0.9, paint);
    canvas.drawCircle(Offset(centerX * 1.2, centerY * 1.3), radius * 0.9, paint);
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
        final scale = 0.95 + (math.sin((animation.value + offset) * math.pi * 2) * 0.05);
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
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.7),
        Radius.circular(size.width * 0.1),
      ));
    canvas.drawPath(binPath, binPaint);

    // Lid with rounded corners
    final lidPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.25),
        Radius.circular(size.width * 0.15),
      ));
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
        final scale = 1.0 + (math.sin((animation.value + offset) * math.pi * 2) * 0.08);
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
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.5, size.width * 0.2, size.height * 0.5),
        Radius.circular(size.width * 0.05),
      ));
    canvas.drawPath(trunkPath, trunkPaint);

    // Foliage (rounded circles) - CHANGED TO LIGHT BLUE
    final foliagePaint = Paint()
      ..color = const Color(0xFFADD8E6).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), size.width * 0.35, foliagePaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.35), size.width * 0.25, foliagePaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), size.width * 0.25, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




// Floating Email Icon (for success celebration)
class _FloatingEmailIcon extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final double offset;

  const _FloatingEmailIcon({
    required this.animation,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final floatY = math.sin((animation.value + offset) * math.pi * 2) * 15;
        final floatX = math.cos((animation.value + offset) * math.pi * 2) * 8;
        final opacity = (math.sin((animation.value + offset) * math.pi * 2) + 1) / 2;
        return Transform.translate(
          offset: Offset(floatX, floatY),
          child: Opacity(
            opacity: opacity * 0.4,
            child: Icon(
              Icons.email_outlined,
              size: size,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }
}