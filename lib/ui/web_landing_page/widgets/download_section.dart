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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width > 1400 ? 120 : 24,
        vertical: 80,
      ),
      child: Container(
        height: 520,
        padding: const EdgeInsets.symmetric(
          horizontal: 64,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
            Positioned(
              top: -30,
              right: -30,
              child: Icon(
                Icons.eco_outlined,
                size: 220,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: Icon(
                Icons.eco_outlined,
                size: 180,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ready to Transform Organic Waste Into\nSustainable Gold?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width > 900 ? 52 : 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: width > 1200 ? 800 : 720,
                    child: Text(
                      'Accel-O-Rot makes smart composting accessible. Start your journey toward a cleaner, greener Philippines today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Updated button with consistent styling
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onDownload,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFF22C55E)),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                      child: const Text(
                        'Download APK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}