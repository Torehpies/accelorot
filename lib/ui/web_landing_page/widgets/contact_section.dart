// lib/ui/web_landing_page/widgets/contact_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class ContactSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onDownload;

  const ContactSection({
    super.key,
    required this.onGetStarted,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxxl * 2),
            color: const Color(0xFF25282B), // Dark background
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/Accel-O-Rot Logo.svg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                                semanticsLabel: 'Accel-O-Rot Logo',
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Accel-O-Rot',
                                style: h2Style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Smart Rotary Drum System for Accelerated Organic Waste Decomposition and Sustainable Composting in the Philippines.',
                            style: WebTextStyles.caption.copyWith(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              // Facebook (valid)
                              _SocialIcon(icon: Icons.facebook_outlined),
                              const SizedBox(width: AppSpacing.md),
                              // Twitter → replaced with public (globe icon)
                              _SocialIcon(icon: Icons.public),
                              const SizedBox(width: AppSpacing.md),
                              // Instagram → replaced with camera (valid fallback)
                              _SocialIcon(icon: Icons.camera_alt_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                    _FooterColumn(
                      title: 'Quick Links',
                      links: [
                        'How It Works',
                        'Features',
                        'Impact',
                        'Contact'
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                    _FooterColumn(
                      title: 'Resources',
                      links: [
                        'RA 9003 Compliance',
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Us',
                            style: WebTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ContactRow(
                            icon: Icons.location_on_outlined,
                            text: 'Metro Manila, Caloocan City, Philippines',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ContactRow(
                            icon: Icons.email_outlined,
                            text: 'support@accel-o-rot.ph',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ContactRow(
                            icon: Icons.phone_outlined,
                            text: '+63 000 000 0000',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Divider
                Container(height: 1, color: const Color(0xFF374151)),
                const SizedBox(height: AppSpacing.md),
                // Copyright & Legal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2026 Accel-O-Rot. All rights reserved. Made with 🌱 in the Philippines.',
                      style: WebTextStyles.caption.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Privacy Policy',
                          style: WebTextStyles.caption.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Text(
                          'Terms of Service',
                          style: WebTextStyles.caption.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadAppButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DownloadAppButton({required this.onTap});

  @override
  State<_DownloadAppButton> createState() => _DownloadAppButtonState();
}

class _DownloadAppButtonState extends State<_DownloadAppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF28A85A), width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [BoxShadow(
                    color: const Color(0xFF28A85A).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 18, color: const Color(0xFF28A85A)),
              const SizedBox(width: 8),
              Text(
                'Download App',
                style: TextStyle(
                  fontFamily: 'dm-sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF28A85A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatefulWidget {
  final VoidCallback onTap;

  const _GetStartedButton({required this.onTap});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF2D9B6B) : const Color(0xFF28A85A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF28A85A).withValues(alpha: (_isHovered ? 0.3 : 0.15)),
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started Today',
                style: TextStyle(
                  fontFamily: 'dm-sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WebTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var link in links) ...[
            _FooterLink(text: link),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          text,
          style: WebTextStyles.caption.copyWith(
            color: const Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: WebTextStyles.caption.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}