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
      color: Colors.white,
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
              color: const Color(0xFF6B7280),
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
          // Contact Cards
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 900;
              
              return isMobile
                  ? Column(
                      children: [
                        _ContactCard(
                          icon: Icons.email_outlined,
                          title: 'Email Us',
                          subtitle: 'support@accel-o-rot.com',
                          onTap: () {},
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ContactCard(
                          icon: Icons.phone_outlined,
                          title: 'Call Us',
                          subtitle: '+63 000 000 0000',
                          onTap: () {},
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ContactCard(
                          icon: Icons.location_on_outlined,
                          title: 'Visit Us',
                          subtitle: 'Metro Manila, Philippines',
                          onTap: () {},
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.email_outlined,
                            title: 'Email Us',
                            subtitle: 'support@accel-o-rot.com',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.phone_outlined,
                            title: 'Call Us',
                            subtitle: '+63 000 000 0000',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.location_on_outlined,
                            title: 'Visit Us',
                            subtitle: 'Metro Manila, Philippines',
                            onTap: () {},
                          ),
                        ),
                      ],
                    );
            },
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
                ? const Color(0xFFF3F4F6)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFFE5E7EB),
              width: 1.5,
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
                  color: _isHovered
                      ? WebColors.greenAccent.withValues(alpha: 0.15)
                      : const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: _isHovered
                      ? WebColors.greenAccent
                      : WebColors.iconsPrimary,
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
                        color: const Color(0xFF6B7280),
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