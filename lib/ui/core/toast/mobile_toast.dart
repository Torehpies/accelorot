// lib/ui/core/toast/mobile_toast.dart

import 'package:flutter/material.dart';
import 'toast_type.dart';
import '../themes/web_text_styles.dart';

class MobileToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismissed;

  const MobileToast({
    super.key,
    required this.message,
    required this.onDismissed,
    this.type = ToastType.success,
  });

  @override
  State<MobileToast> createState() => _MobileToastState();
}

class _MobileToastState extends State<MobileToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Slide down from above the screen
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Animate out then call onDismissed
  Future<void> _dismiss() async {
    if (_controller.isAnimating) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: type.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: type.borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(type.icon, color: type.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Message
                  Flexible(
                    child: Text(
                      widget.message,
                      style: WebTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}