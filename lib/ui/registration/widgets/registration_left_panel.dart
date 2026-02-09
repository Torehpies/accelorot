import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class RegistrationLeftPanel extends StatefulWidget {
  const RegistrationLeftPanel({super.key});

  @override
  State<RegistrationLeftPanel> createState() => _RegistrationLeftPanelState();
}

class _RegistrationLeftPanelState extends State<RegistrationLeftPanel>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _blobController;
  late AnimationController _cloudController;

  @override
  void initState() {
    super.initState();

    // Floating up and down animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Gentle rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Scale pulse animation
    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Blob morph animation
    _blobController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    // Cloud floating animation
    _cloudController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _blobController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final size = MediaQuery.of(context).size;
    final isSmallHeight = size.height < 700;
    
    // Scale decorative elements based on available space
    final blobSize1 = (size.width * 0.6).clamp(200.0, 300.0);
    final blobSize2 = (size.width * 0.7).clamp(250.0, 350.0);
    final cloudSize1 = (size.width * 0.2).clamp(80.0, 100.0);
    final cloudSize2 = (size.width * 0.28).clamp(100.0, 140.0);
    final cloudSize3 = (size.width * 0.18).clamp(70.0, 90.0);
    
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // Light green
              Color(0xFFDCEDC8), // Slightly darker green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated decorative background blobs (responsive positioning)
            Positioned(
              top: -(blobSize1 * 0.27),
              right: -(blobSize1 * 0.27),
              child: _AnimatedDecorativeBlob(
                animation: _blobController,
                size: blobSize1,
                color: AppColors.green100.withValues(alpha: 0.15),
                offset: 0,
              ),
            ),
            Positioned(
              bottom: -(blobSize2 * 0.29),
              left: -(blobSize2 * 0.29),
              child: _AnimatedDecorativeBlob(
                animation: _blobController,
                size: blobSize2,
                color: AppColors.green100.withValues(alpha: 0.1),
                offset: 0.5,
              ),
            ),

            // Animated clouds (responsive sizing)
            Positioned(
              top: size.height * 0.08,
              left: -cloudSize1 * 0.4,
              child: _FloatingCloud(
                animation: _cloudController,
                size: cloudSize1,
                color: const Color(0xFFF0F8FF).withValues(alpha: 0.7),
                offset: 0.0,
              ),
            ),
            Positioned(
              top: size.height * 0.15,
              right: -cloudSize2 * 0.43,
              child: _FloatingCloud(
                animation: _cloudController,
                size: cloudSize2,
                color: const Color(0xFFE6F7FF).withValues(alpha: 0.8),
                offset: 0.3,
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              left: size.width * 0.1,
              child: _FloatingCloud(
                animation: _cloudController,
                size: cloudSize3,
                color: const Color(0xFFE3F2FD).withValues(alpha: 0.75),
                offset: 0.6,
              ),
            ),

            // Floating leaves (responsive positioning)
            Positioned(
              top: size.height * 0.15,
              left: size.width * 0.1,
              child: _FloatingLeaf(
                animation: _floatingController,
                rotationAnimation: _rotationController,
                size: 30,
                offset: 0,
              ),
            ),
            Positioned(
              bottom: size.height * 0.28,
              right: size.width * 0.15,
              child: _FloatingLeaf(
                animation: _floatingController,
                rotationAnimation: _rotationController,
                size: 40,
                offset: 0.5,
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              right: size.width * 0.25,
              child: _FloatingLeaf(
                animation: _floatingController,
                rotationAnimation: _rotationController,
                size: 25,
                offset: 0.3,
              ),
            ),
            Positioned(
              top: size.height * 0.55,
              left: size.width * 0.2,
              child: _FloatingLeaf(
                animation: _floatingController,
                rotationAnimation: _rotationController,
                size: 35,
                offset: 0.7,
              ),
            ),

            // Main content (no scroll, minimized padding)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated composting illustration (responsive)
                    _AnimatedCompostingIllustration(
                      floatingAnimation: _floatingController,
                      scaleAnimation: _scaleController,
                      size: isSmallHeight ? 180.0 : 240.0,
                    ),

                    SizedBox(height: isSmallHeight ? 30 : 40),

                    // Title with fade-in (responsive font size)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Nurture Nature',
                        style: TextStyle(
                          color: const Color(0xFF2D3748),
                          fontSize: isSmallHeight ? 26 : 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: isSmallHeight ? 12 : 16),

                    // Subtitle with delayed fade-in
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Turn waste into wonder. Join\nthe smart composting\nrevolution today.',
                        style: TextStyle(
                          color: const Color(0xFF4A5568),
                          fontSize: isSmallHeight ? 13 : 15,
                          height: 1.5,
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
    );
  }
}

// Animated Composting Illustration
class _AnimatedCompostingIllustration extends StatelessWidget {
  final Animation<double> floatingAnimation;
  final Animation<double> scaleAnimation;
  final double size;

  const _AnimatedCompostingIllustration({
    required this.floatingAnimation,
    required this.scaleAnimation,
    this.size = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([floatingAnimation, scaleAnimation]),
      builder: (context, child) {
        final floatOffset = math.sin(floatingAnimation.value * math.pi * 2) * 15;
        final scale = size / 280.0; // Scale relative to default size

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background leaves with staggered animation (scaled)
                Positioned(
                  top: 60 * scale,
                  left: 60 * scale,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.0,
                    width: 80 * scale,
                    height: 120 * scale,
                    color: AppColors.green100.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  top: 50 * scale,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.3,
                    width: 90 * scale,
                    height: 130 * scale,
                    color: AppColors.green100.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: 60 * scale,
                  right: 60 * scale,
                  child: _AnimatedLeaf(
                    animation: floatingAnimation,
                    rotationOffset: 0.6,
                    width: 80 * scale,
                    height: 120 * scale,
                    color: AppColors.green100.withValues(alpha: 0.4),
                  ),
                ),

                // Composting drum (scaled)
                Positioned(
                  bottom: 40 * scale,
                  child: Transform.scale(
                    scale: scale,
                    child: _CompostDrum(),
                  ),
                ),

                // Animated sprouts (scaled)
                Positioned(
                  bottom: 130 * scale,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedSprout(
                        animation: scaleAnimation,
                        height: 30 * scale,
                        delay: 0,
                      ),
                      SizedBox(width: 20 * scale),
                      _AnimatedSprout(
                        animation: scaleAnimation,
                        height: 35 * scale,
                        delay: 0.5,
                      ),
                    ],
                  ),
                ),

                // Animated particles (scaled)
                ..._buildFloatingParticles(floatingAnimation, scale),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles(Animation<double> animation, double scale) {
    return List.generate(3, (index) {
      final offset = index * 0.3;
      return Positioned(
        top: (180 + (index * 30)) * scale,
        left: (100 + (index * 20)) * scale,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final floatY = math.sin((animation.value + offset) * math.pi * 2) * 10;
            final opacity =
                (math.sin((animation.value + offset) * math.pi * 2) + 1) / 2;

            return Transform.translate(
              offset: Offset(0, floatY),
              child: Opacity(
                opacity: opacity * 0.5,
                child: SizedBox(
                  width: 8 * scale,
                  height: 8 * scale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.green100,
                      shape: BoxShape.circle,
                    ),
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

// Animated Leaf
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
        final rotation =
            math.sin((animation.value + rotationOffset) * math.pi * 2) * 0.1;
        final scale = 1.0 +
            (math.sin((animation.value + rotationOffset) * math.pi * 2) * 0.05);

        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size(width, height),
              painter: _LeafPainter(color),
            ),
          ),
        );
      },
    );
  }
}

// Animated Sprout
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
        final scale =
            1.0 + (math.sin((animation.value + delay) * math.pi * 2) * 0.1);

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Leaf top
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              // Stem
              SizedBox(
                width: 3,
                height: 30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(2),
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

// Composting drum (static)
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

    // Main drum body (trapezoid shape)
    final drumPath = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(drumPath, drumPaint);
    canvas.drawPath(drumPath, drumStroke);

    // Vertical slats
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

// Leaf painter
class _LeafPainter extends CustomPainter {
  final Color color;

  _LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

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

// Animated decorative blob
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
          child: SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Floating leaf decoration
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

// Floating cloud decoration
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
        // Gentle floating motion (vertical)
        final floatY = math.sin((animation.value + offset) * math.pi * 2) * 8;
        // Slow horizontal drift
        final driftX = math.cos((animation.value + offset) * math.pi * 2) * 5;
        // Subtle scale pulsing
        final scale =
            0.95 + (math.sin((animation.value + offset * 2) * math.pi * 2) * 0.05);

        return Transform.translate(
          offset: Offset(driftX, floatY),
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size(size, size * 0.6),
              painter: _CloudPainter(color),
            ),
          ),
        );
      },
    );
  }
}

// Cloud painter - soft fluffy cloud shape
class _CloudPainter extends CustomPainter {
  final Color color;

  _CloudPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create a soft cloud shape using overlapping circles
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.height * 0.45;

    // Main body circles
    canvas.drawCircle(Offset(centerX * 0.6, centerY), radius, paint);
    canvas.drawCircle(Offset(centerX, centerY * 0.8), radius * 1.2, paint);
    canvas.drawCircle(Offset(centerX * 1.4, centerY), radius, paint);
    canvas.drawCircle(Offset(centerX * 0.8, centerY * 1.3), radius * 0.9, paint);
    canvas.drawCircle(Offset(centerX * 1.2, centerY * 1.3), radius * 0.9, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
