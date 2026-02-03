// lib/ui/web_landing_page/widgets/banner_section.dart
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
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF22C55E),
            ],
          ),
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
                  // ✅ CENTERED DOWNLOAD BUTTON (only one button now)
                  SizedBox(
                    width: 260, // Consistent width for single button
                    child: OutlinedButton(
                      onPressed: onDownload,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.download_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Download APk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                        ],
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