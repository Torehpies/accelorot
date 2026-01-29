// lib/ui/web_landing_page/widgets/contact_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class ContactSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onDownload;
  final Function(String)? onNavigateToSection;

  const ContactSection({
    super.key,
    required this.onGetStarted,
    this.onDownload,
    this.onNavigateToSection,
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
                              _SocialIcon(icon: Icons.facebook_outlined),
                              const SizedBox(width: AppSpacing.md),
                              _SocialIcon(icon: Icons.public),
                              const SizedBox(width: AppSpacing.md),
                              _SocialIcon(icon: Icons.camera_alt_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                    _FooterColumn(
                      title: 'Quick Links',
                      links: const [
                        'Features',
                        'How It Works',
                        'Impact',
                        'Join Us',
                      ],
                      onLinkTap: (link) {
                        if (onNavigateToSection != null) {
                          switch (link) {
                            case 'Features':
                              onNavigateToSection!('features');
                              break;
                            case 'How It Works':
                              onNavigateToSection!('how-it-works');
                              break;
                            case 'Impact':
                              onNavigateToSection!('impact');
                              break;
                            case 'Join Us':
                              onNavigateToSection!('banner');
                              break;
                          }
                        }
                      },
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                    _FooterColumn(
                      title: 'Resources',
                      links: const [
                        'RA 9003 Compliance',
                      ],
                      onLinkTap: (link) {
                        // Handle resource links if needed
                      },
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
  final Function(String)? onLinkTap;

  const _FooterColumn({
    required this.title,
    required this.links,
    this.onLinkTap,
  });

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
            _FooterLink(
              text: link,
              onTap: onLinkTap != null ? () => onLinkTap!(link) : null,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _FooterLink({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
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