import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart'; 
import 'package:flutter_application_1/ui/login/views/login_form.dart';

class DesktopLoginView extends StatefulWidget {
  const DesktopLoginView({super.key});

  @override
  State<DesktopLoginView> createState() => _DesktopLoginViewState();
}

class _DesktopLoginViewState extends State<DesktopLoginView>
    with TickerProviderStateMixin {
  late final AnimationController _blobController;
  late final AnimationController _cloudController;
  late final AnimationController _floatingController;
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;

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
  }

  @override
  void dispose() {
    _blobController.dispose();
    _cloudController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Animated Onboarding Illustration
        Expanded(
          flex: 3,
          child: RepaintBoundary(
            child: ClipRRect(
              // REMOVED BORDER RADIUS HERE
              borderRadius: BorderRadius.zero,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8F5E9),
                      Color(0xFFDCEDC8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -80,
                      child: _AnimatedDecorativeBlob(
                        animation: _blobController,
                        size: 300,
                        color: AppColors.green100.withValues(alpha: 0.15),
                        offset: 0,
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -100,
                      child: _AnimatedDecorativeBlob(
                        animation: _blobController,
                        size: 350,
                        color: AppColors.green100.withValues(alpha: 0.1),
                        offset: 0.5,
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: -40,
                      child: _FloatingCloud(
                        animation: _cloudController,
                        size: 100,
                        color: const Color(0xFFF0F8FF).withValues(alpha: 0.7),
                        offset: 0.0,
                      ),
                    ),
                    Positioned(
                      top: 120,
                      right: -60,
                      child: _FloatingCloud(
                        animation: _cloudController,
                        size: 140,
                        color: const Color(0xFFE6F7FF).withValues(alpha: 0.8),
                        offset: 0.3,
                      ),
                    ),
                    Positioned(
                      top: 200,
                      left: 40,
                      child: _FloatingCloud(
                        animation: _cloudController,
                        size: 90,
                        color: const Color(0xFFE3F2FD).withValues(alpha: 0.75),
                        offset: 0.6,
                      ),
                    ),
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
                      top: 250,
                      right: 100,
                      child: _FloatingLeaf(
                        animation: _floatingController,
                        rotationAnimation: _rotationController,
                        size: 25,
                        offset: 0.3,
                      ),
                    ),
                    Positioned(
                      top: 400,
                      left: 80,
                      child: _FloatingLeaf(
                        animation: _floatingController,
                        rotationAnimation: _rotationController,
                        size: 35,
                        offset: 0.7,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimatedCompostingIllustration(
                              floatingAnimation: _floatingController,
                              scaleAnimation: _scaleController,
                            ),
                            const SizedBox(height: 60),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child!,
                                  ),
                                );
                              },
                              child: const Text(
                                'Nurture Nature',
                                style: TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child!,
                                  ),
                                );
                              },
                              child: const Text(
                                'Turn waste into wonder\n.'
                                'Join the smart composting\n'
                                'revolution today.',
                                style: TextStyle(
                                  color: Color(0xFF4A5568),
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right Side: Form
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480), // kMaxFormWidth
                child: const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: LoginForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Reused widgets below (unchanged logic, just fixed AppColors usage) ---

class _AnimatedCompostingIllustration extends StatelessWidget {
  final Animation<double> floatingAnimation;
  final Animation<double> scaleAnimation;

  const _AnimatedCompostingIllustration({
    required this.floatingAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([floatingAnimation, scaleAnimation]),
      builder: (context, child) {
        final floatOffset =
            math.sin(floatingAnimation.value * math.pi * 2) * 15;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 60,
                  left: 60,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.0,
                    width: 80,
                    height: 120,
                    color: AppColors.green100.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.3,
                    width: 90,
                    height: 130,
                    color: AppColors.green100.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 60,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.6,
                    width: 80,
                    height: 120,
                    color: AppColors.green100.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  child: _CompostDrum(),
                ),
                Positioned(
                  bottom: 130,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedSprout(animation: scaleAnimation, height: 30, delay: 0),
                      const SizedBox(width: 20),
                      _AnimatedSprout(animation: scaleAnimation, height: 35, delay: 0.5),
                    ],
                  ),
                ),
                ..._buildFloatingParticles(floatingAnimation),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _buildFloatingParticles(Animation<double> animation) {
    return List.generate(3, (index) {
      final offset = index * 0.3;
      return Positioned(
        top: 180 + (index * 30),
        left: 100 + (index * 20),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final floatY = math.sin((animation.value + offset) * math.pi * 2) * 10;
            final opacity = (math.sin((animation.value + offset) * math.pi * 2) + 1) / 2;
            return Transform.translate(
              offset: Offset(0, floatY),
              child: Opacity(
                opacity: opacity * 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.green100,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _AnimatedLeaf extends StatelessWidget {
  final Animation<double> animation;
  final double rotationOffset;
  final double width;
  final double height;
  final Color color;

  const _AnimatedLeaf({
    required this.animation,
    required this.rotationOffset,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rotation = math.sin((animation.value + rotationOffset) * math.pi * 2) * 0.1;
        final scale = 1.0 + (math.sin((animation.value + rotationOffset) * math.pi * 2) * 0.05);
        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.5),
              child: CustomPaint(
                size: Size(width, height),
                painter: _LeafPainter(color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSprout extends StatelessWidget {
  final Animation<double> animation;
  final double height;
  final double delay;

  const _AnimatedSprout({
    required this.animation,
    required this.height,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + (math.sin((animation.value + delay) * math.pi * 2) * 0.1);
        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.green100,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 3,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompostDrum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 160,
        height: 100,
        child: CustomPaint(
          painter: _DrumPainter(),
        ),
      ),
    );
  }
}

class _DrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final drumPaint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..style = PaintingStyle.fill;
    final drumStroke = Paint()
      ..color = const Color(0xFF6B5235)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final drumPath = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(drumPath, drumPaint);
    canvas.drawPath(drumPath, drumStroke);

    for (int i = 1; i < 4; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(
        Offset(x - 5, 0),
        Offset(x + 5, size.height),
        drumStroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.3,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.3,
        size.width / 2,
        0,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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