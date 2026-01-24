// lib/ui/landing_page/widgets/contact_cta_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

// ========================================================
// CONTACT SECTION
// ========================================================

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
                          subtitle: '+63 912 345 6789',
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
                            subtitle: '+63 912 345 6789',
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

// ========================================================
// CONTACT CARD WIDGET
// ========================================================

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

// ========================================================
// CTA SECTION
// ========================================================

class CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onDownload;

  const CtaSection({
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
          // ================= CTA CONTAINER WITH GRADIENT =================
          Container(
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
                  Color(0xFF84FAB0), // start green
                  Color(0xFF8FD3F4), // end blue
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Ready to Transform Your Waste\nManagement?',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.h1.copyWith(
                    color: WebColors.textTitle,
                    fontSize: 40,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Join the sustainable composting revolution with Accel-O-Rot\'s smart IoT\nsystem',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.subtitle.copyWith(
                    color: const Color(0xFF111827),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // ================= BUTTONS ROW =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Download App Button
                    if (onDownload != null) ...[
                      _DownloadAppButton(onTap: onDownload!),
                      const SizedBox(width: AppSpacing.lg),
                    ],
                    // Get Started Button
                    _GetStartedButton(onTap: onGetStarted),
                  ],
                ),
              ],
            ),
          ),
          // ================= FOOTER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl * 2,
              vertical: AppSpacing.xl,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      'ACCEL-O-ROT',
                      style: h2Style.copyWith(
                        color: WebColors.textTitle,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    '© 2026 Accel-O-Rot. Accelerating sustainable composting through innovation.',
                    style: WebTextStyles.caption.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// DOWNLOAD APP BUTTON
// ========================================================

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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF28A85A),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF28A85A).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_outlined,
                size: 18,
                color: const Color(0xFF28A85A),
              ),
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

// ========================================================
// GET STARTED BUTTON
// ========================================================

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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF2D9B6B)
                : const Color(0xFF28A85A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF28A85A).withOpacity(
                  _isHovered ? 0.3 : 0.15,
                ),
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
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}