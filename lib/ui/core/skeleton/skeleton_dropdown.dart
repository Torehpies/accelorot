// lib/ui/core/skeleton/skeleton_dropdown.dart

import 'package:flutter/material.dart';

/// A skeleton loader that mimics the MobileDropdownField appearance
class SkeletonDropdown extends StatefulWidget {
  final String label;
  final bool showRequired;

  const SkeletonDropdown({
    super.key,
    required this.label,
    this.showRequired = false,
  });

  @override
  State<SkeletonDropdown> createState() => _SkeletonDropdownState();
}

class _SkeletonDropdownState extends State<SkeletonDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: InputDecorator(
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: widget.label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  children: [
                    if (widget.showRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(right: 100),
            ),
          ),
        );
      },
    );
  }
}