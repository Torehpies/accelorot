import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';

class ContactSection extends StatelessWidget {
  final ValueChanged<String>? onNavigateToSection;

  const ContactSection({
    super.key,
    this.onNavigateToSection,
  });

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString.trim());
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _launchGmailCompose() async {
    final email = 'accelorot.management@gmail.com';
    final subject = 'Inquiry from Accel-O-Rot Website';

    final gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject'
    );

    if (!await launchUrl(gmailUri)) {
      final mailtoUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': subject},
      );
      if (!await launchUrl(mailtoUri)) {
        debugPrint('Could not launch email client');
      }
    }
  }

  void _handleLinkNavigation(BuildContext context, String linkText) {
    switch (linkText) {
      case 'Privacy Policy':
        context.go('/privacy-policy');
        break;
      case 'Terms of Service':
        context.go('/terms-of-service');
        break;
      case 'Features':
        onNavigateToSection?.call('features');
        break;
      case 'How It Works':
        onNavigateToSection?.call('how-it-works');
        break;
      case 'Impact':
        onNavigateToSection?.call('impact');
        break;
      case 'Download':
        onNavigateToSection?.call('download');
        break;
      case 'FAQ':
        onNavigateToSection?.call('faq');
        break;
      default:
        onNavigateToSection?.call(linkText.toLowerCase().replaceAll(' ', '-'));
    }
  }

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
            color: const Color(0xFF25282B),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ UPDATED: Logo with new filename and matching styling
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => onNavigateToSection?.call('home'),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/Accelorot_logo.svg',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.contain,
                                        semanticsLabel: 'Accelorot_logo',
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Text(
                                        'Accel-O-Rot',
                                        style: h2Style.copyWith(
                                          color: WebColors.buttonsPrimary, 
                                          fontWeight: FontWeight.w900, 
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  _SocialIcon(
                                    iconData: Icons.facebook_outlined,
                                    onPressed: () => _launchUrl('https://www.facebook.com/share/1BmNSogMqh/'),
                                    backgroundColor: const Color(0xFF1877F2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FooterColumn(
                            title: 'Quick Links',
                            links: const [
                              'Features',
                              'How It Works',
                              'Impact',
                              'Download',
                              'FAQ',
                            ],
                            onLinkTap: (link) => _handleLinkNavigation(context, link),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          _FooterColumn(
                            title: 'Legal Policies',
                            links: const [
                              'Privacy Policy',
                              'Terms of Service',
                            ],
                            onLinkTap: (link) => _handleLinkNavigation(context, link),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          _FooterColumn(
                            title: 'Contact Us',
                            links: const [],
                            onLinkTap: null,
                            customContent: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ContactRow(
                                  icon: Icons.location_on_outlined,
                                  text: 'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines',
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _ContactRow(
                                  icon: Icons.email_outlined,
                                  text: 'accelorot.management@gmail.com',
                                  onTap: _launchGmailCompose,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _ContactRow(
                                  icon: Icons.phone_outlined,
                                  text: '+63 951 000 7296',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.xxxl),
                              child: _FooterColumn(
                                title: 'Quick Links',
                                links: const [
                                  'Features',
                                  'How It Works',
                                  'Impact',
                                  'Download',
                                  'FAQ',
                                ],
                                onLinkTap: (link) => _handleLinkNavigation(context, link),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                              child: _FooterColumn(
                                title: 'Legal Policies',
                                links: const [
                                  'Privacy Policy',
                                  'Terms of Service',
                                ],
                                onLinkTap: (link) => _handleLinkNavigation(context, link),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _FooterColumn(
                              title: 'Contact Us',
                              links: const [],
                              onLinkTap: null,
                              customContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ContactRow(
                                    icon: Icons.location_on_outlined,
                                    text: 'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines',
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _ContactRow(
                                    icon: Icons.email_outlined,
                                    text: 'accelorot.management@gmail.com',
                                    onTap: _launchGmailCompose,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _ContactRow(
                                    icon: Icons.phone_outlined,
                                    text: '+63 951 000 7296',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: AppSpacing.xxxl),
                    Container(height: 1, color: const Color(0xFF374151)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '© 2026 Accel-O-Rot. All rights reserved.',
                      style: WebTextStyles.caption.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---
class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  final ValueChanged<String>? onLinkTap;
  final Widget? customContent;

  const _FooterColumn({
    required this.title,
    required this.links,
    this.onLinkTap,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (customContent != null)
          customContent!
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < links.length; i++)
                Column(
                  children: [
                    _FooterLink(
                      text: links[i],
                      onTap: () => onLinkTap?.call(links[i]),
                    ),
                    if (i < links.length - 1) 
                      const SizedBox(height: AppSpacing.md),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const _SocialIcon({
    required this.iconData,
    this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(iconData, color: Colors.white, size: 20),
      ),
    );

    if (onPressed != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: child,
        ),
      );
    }

    return child;
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
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
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

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}