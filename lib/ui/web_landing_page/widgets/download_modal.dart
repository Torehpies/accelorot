import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';

class DownloadModal extends StatefulWidget {
  final VoidCallback onClose;

  const DownloadModal({super.key, required this.onClose});

  @override
  State<DownloadModal> createState() => _DownloadModalState();
}

class _DownloadModalState extends State<DownloadModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop with blur
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
        // Modal Content
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F2FE),
                      Color(0xFFCCFBF1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Device Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF49D47F),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.smartphone_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Title
                          Text(
                            'Download the Accel-O-Rot\nApp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'dm-sans',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D6B3C).withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Description
                          Text(
                            'Monitor your composting system from anywhere. Get real-time alerts, view analytics, and control your device right from your phone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'dm-sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color:  Color(0xFF0D6B3C).withValues(alpha: 0.85),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          // Download Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF49D47F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Handle download
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Download started: Accel-O-Rot v1.0.0.apk'),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.download_outlined,
                                        color: Color(0xFF0D6B3C),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Download Accel-O-Rot',
                                            style: TextStyle(
                                              fontFamily: 'dm-sans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0D6B3C),
                                            ),
                                          ),
                                          Text(
                                            'v1.0.0.apk',
                                            style: TextStyle(
                                              fontFamily: 'dm-sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF0D6B3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D6B3C)
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '25 MB',
                                          style: TextStyle(
                                            fontFamily: 'dm-sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0D6B3C).withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Compatibility Info
                          Text(
                            'Compatible with Android 8.0 and above',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'dm-sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0D6B3C).withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close Button
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.green,
                            size: 18,
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
      ],
    );
  }
}
