import 'package:flutter/material.dart';

class StatisticCardSkeleton extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String subtitle;

  const StatisticCardSkeleton({
    super.key,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withAlpha(26),
                  width: 3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                // Skeleton for current value
                _SkeletonBox(
                  width: 80,
                  height: 24,
                  color: accentColor.withAlpha(51),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton Progress Bar
                _SkeletonBox(
                  width: double.infinity,
                  height: 40,
                  color: accentColor.withAlpha(26),
                ),
                const SizedBox(height: 20),

                // Skeleton Chart
                Container(
                  height: 362,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Y-axis skeleton
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => _SkeletonBox(
                              width: 35,
                              height: 10,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      // X-axis skeleton
                      Positioned(
                        left: 45,
                        right: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) => _SkeletonBox(
                              width: 40,
                              height: 10,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      // Chart area with shimmer effect
                      Positioned(
                        left: 45,
                        right: 10,
                        top: 10,
                        bottom: 40,
                        child: _ShimmerBox(
                          color: accentColor.withAlpha(13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                const Divider(
                  height: 3,
                  thickness: 3,
                  color: Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 16),

                // More Information Section
                const Text(
                  'More Information:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildSkeletonInfo(),
                const SizedBox(height: 4), // Extra bottom spacing
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildSkeletonInfo() {
    return [
      ...List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SkeletonBox(
                  width: double.infinity,
                  height: 13,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 2), // Add a bit more padding to match real card
    ];
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final Color color;

  const _ShimmerBox({required this.color});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color,
                widget.color.withAlpha(128),
                widget.color,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}