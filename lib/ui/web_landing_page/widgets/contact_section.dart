// lib/ui/landing_page/widgets/contact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl * 2,
        vertical: AppSpacing.xxxl * 3,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFCCFBF1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'Get in Touch with\nAccel-O-Rot',
            style: WebTextStyles.h1.copyWith(
              color: WebColors.textTitle,
              fontSize: 40,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Subheading
          Text(
            'Have questions about our smart composting system? We\'re here to help you start your sustainable journey.',
            style: WebTextStyles.subtitle.copyWith(
              color: WebColors.textTitle,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
          // Contact Cards
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'support@accel-o-rot.com',
                  onTap: () {
                    // Handle email tap - could open email client
                    // Example: launch('mailto:support@accel-o-rot.com');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: _ContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '+63 000 000 0000',
                  onTap: () {
                    // Handle call tap - could open phone dialer
                    // Example: launch('tel:+639123456789');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: _ContactCard(
                  icon: Icons.location_on_outlined,
                  title: 'Visit Us',
                  subtitle: 'Metro Manila, Philippines',
                  onTap: () {
                    // Handle location tap - could open maps
                    // Example: launch('https://maps.google.com/...');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: _isHovered
            //WebColors.textTitle,
                ? WebColors.textTitle.withValues(alpha: 0.25)
                : WebColors.textTitle.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? WebColors.textTitle.withValues(alpha: 0.4)
                  : WebColors.textTitle.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: WebColors.textTitle.withValues(
                    alpha: _isHovered ? 0.3 : 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'dm-sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: WebColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'dm-sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: WebColors.textTitle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}