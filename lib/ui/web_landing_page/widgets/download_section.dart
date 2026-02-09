// lib/ui/web_landing_page/widgets/download_section.dart
import 'package:flutter/material.dart';

class DownloadSection extends StatelessWidget {
  final VoidCallback onDownload;

  const DownloadSection({
    super.key,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : isTablet ? 32 : (width > 1400 ? 120 : 24),
        vertical: isMobile ? 40 : 80,
      ),
      child: Container(
        height: isMobile ? 600 : isTablet ? 520 : 520,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : isTablet ? 40 : 64,
          vertical: isMobile ? 32 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF22C55E),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative icons
            if (!isMobile)
              Positioned(
                top: -30,
                right: -30,
                child: Icon(
                  Icons.eco_outlined,
                  size: 220,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            if (!isMobile)
              Positioned(
                bottom: -40,
                left: -30,
                child: Icon(
                  Icons.eco_outlined,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            // Mobile background icons (smaller)
            if (isMobile)
              Positioned(
                top: -20,
                right: -20,
                child: Icon(
                  Icons.eco_outlined,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            if (isMobile)
              Positioned(
                bottom: -30,
                left: -20,
                child: Icon(
                  Icons.eco_outlined,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main heading
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 0,
                      ),
                      child: Text(
                        'Ready to Transform Organic Waste Into Sustainable Gold?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 28
                              : isTablet
                                  ? 40
                                  : (width > 900 ? 52 : 36),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    // Description text
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile
                            ? width - 40
                            : isTablet
                                ? 500
                                : (width > 1200 ? 800 : 720),
                      ),
                      child: Text(
                        'Accel-O-Rot makes smart composting accessible. Start your journey toward a cleaner, greener Philippines today.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : isTablet ? 16 : 18,
                          height: 1.6,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 48),
                    // Download button
                    SizedBox(
                      width: isMobile ? (width - 40) * 0.8 : 260,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onDownload,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all(const Color(0xFF22C55E)),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 12 : 8),
                            ),
                          ),
                          elevation: WidgetStateProperty.resolveWith<double>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return 8;
                              }
                              return 0;
                            },
                          ),
                          shadowColor: WidgetStateProperty.all(
                            Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'Download APK',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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