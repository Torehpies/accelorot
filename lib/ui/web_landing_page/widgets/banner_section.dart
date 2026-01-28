// lib/ui/web_landing_page/widgets/banner_section.dart

import 'package:flutter/material.dart';

class BannerSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onDownload;

  const BannerSection({
    super.key,
    required this.onGetStarted,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 72,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
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
              top: -20,
              right: -20,
              child: Icon(
                Icons.eco_outlined,
                size: 180,
                color: Colors.white.withOpacity(0.08), 
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Icon(
                Icons.eco_outlined,
                size: 140,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.download_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Join the Movement',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ready to Transform Organic Waste Into\nSustainable Gold?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width > 900 ? 44 : 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 720,
                  child: Text(
                    'Whether you\'re a household, school, barangay, or institution, '
                    'Accel-O-Rot makes smart composting accessible. Start your journey '
                    'toward a cleaner, greener Philippines today.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Get Started Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onDownload,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.download_rounded, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Download',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}