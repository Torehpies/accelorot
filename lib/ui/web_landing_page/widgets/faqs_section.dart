import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _expandedIndex;

  Future<void> _launchEmail() async {
    const email = 'accelorot.management@gmail.com';
    const subject = 'Inquiry from Accel-O-Rot Website';

    final gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject',
    );

    if (!await launchUrl(gmailUri)) {
      final mailtoUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': subject},
      );
      if (!await launchUrl(mailtoUri)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to open email client')),
          );
        }
      }
    }
  }

  final List<FaqItem> _faqItems = const [
    FaqItem(
      question: 'What is Accel-O-Rot?',
      answer:
          'Accel-O-Rot is an IoT-enabled smart rotary drum composting system designed to accelerate the decomposition of organic waste. It uses sensors, aeration, and moisture regulation to optimize the composting process, making it faster and more efficient than traditional methods.',
      icon: Icons.eco_outlined,
    ),
    FaqItem(
      question: 'How does the system accelerate composting?',
      answer:
          'The system uses a rotary drum to continuously mix materials for better aeration and homogeneity. It monitors critical environmental parameters—temperature, moisture, and air quality—and uses automated systems to maintain optimal conditions, which can lead to mature compost in as little as 14 days.',
      icon: Icons.speed_outlined,
    ),
    FaqItem(
      question: 'What types of waste can I put in the Accel-O-Rot?',
      answer:
          'The system is designed for organic, biodegradable waste. Users can add a mix of "greens" (e.g., food scraps) and "browns" (e.g., dry leaves) to start the decomposition process.',
      icon: Icons.delete_outline,
    ),
    FaqItem(
      question: 'What are the main benefits for a community or institution?',
      answer:
          'Accel-O-Rot boosts the ability of barangays and LGUs to manage organic waste, lowering hauling expenses and reliance on landfills. It reduces methane emissions, odors, and habitats for disease-carrying pests—enhancing public health while producing nutrient-dense compost for city gardening and landscaping.',
      icon: Icons.groups_outlined,
    ),
    FaqItem(
      question: 'What types of organic waste can be processed?',
      answer:
          'Accel-O-Rot processes biodegradable waste including kitchen greens and dry-leaf browns. The mobile app guides users to balance inputs at the optimal carbon-to-nitrogen ratio of 25:1 to 30:1 for rapid, odor-free decomposition within 14 days.',
      icon: Icons.recycling_outlined,
    ),
    FaqItem(
      question: 'How does the system ensure the final product is safe?',
      answer:
          'The system design follows the Philippine National Standard for Compost (PNS/BAFS PA 1:2019). By monitoring temperature to ensure it reaches the thermophilic phase, the system helps kill harmful pathogens, making the resulting compost safe for urban agriculture and gardening.',
      icon: Icons.verified_user_outlined,
    ),
  ];

  void _toggleCard(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1200;

    // Responsive horizontal padding — clamp to avoid extremes
    final hPad = width > 1400
        ? 120.0
        : width > 900
            ? 64.0
            : width > 600
                ? 32.0
                : 16.0;

    final greenColor = const Color(0xFF2E7D32);
    final baseContactStyle = TextStyle(
      fontFamily: WebTextStyles.faqAnswer.fontFamily,
      fontSize: 16,
      color: Colors.black.withValues(alpha: 0.7),
      height: 1.5,
    );

    return Container(
      color: const Color(0xFAFAFAFA),
      padding: EdgeInsets.fromLTRB(hPad, 56, hPad, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Section Header ───────────────────────────────────────
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontFamily: WebTextStyles.faqSectionTitle.fontFamily,
                  fontSize: width > 600 ? 40 : 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Here's what other people are finding most useful right now:",
                style: TextStyle(
                  fontFamily: WebTextStyles.faqSectionSubtitle.fontFamily,
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Responsive card grid (no fixed aspect ratio) ─────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = isMobile ? 1 : isTablet ? 2 : 3;
                  final spacing = 20.0;
                  final itemWidth = cols == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing * (cols - 1)) / cols;

                  // Build rows manually to allow variable card heights
                  final rows = <Widget>[];
                  for (var r = 0;
                      r < (_faqItems.length / cols).ceil();
                      r++) {
                    final rowItems = <Widget>[];
                    for (var c = 0; c < cols; c++) {
                      final idx = r * cols + c;
                      if (idx >= _faqItems.length) {
                        // Filler to keep columns aligned
                        rowItems.add(SizedBox(width: itemWidth));
                      } else {
                        rowItems.add(
                          SizedBox(
                            width: itemWidth,
                            child: _FaqCard(
                              faq: _faqItems[idx],
                              isExpanded: _expandedIndex == idx,
                              onToggle: () => _toggleCard(idx),
                              greenColor: greenColor,
                            ),
                          ),
                        );
                      }
                      if (c < cols - 1) {
                        rowItems.add(SizedBox(width: spacing));
                      }
                    }
                    rows.add(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rowItems,
                      ),
                    );
                    if (r < (_faqItems.length / cols).ceil() - 1) {
                      rows.add(SizedBox(height: spacing));
                    }
                  }

                  return Column(children: rows);
                },
              ),

              // ── Contact prompt ────────────────────────────────────────
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'If you have any questions, please contact us at ',
                      style: baseContactStyle,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _launchEmail,
                        child: Text(
                          'accelorot.management@gmail.com',
                          style: baseContactStyle.copyWith(
                            color: const Color(0xFF1A73E8),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF1A73E8),
                            decorationThickness: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Text('.', style: baseContactStyle),
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

// ─────────────────────────────────────────────────────────────────────────────

class FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

class _FaqCard extends StatelessWidget {
  final FaqItem faq;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Color greenColor;

  const _FaqCard({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
    required this.greenColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        // No Expanded — card grows with content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: greenColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(faq.icon, size: 20, color: greenColor),
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              faq.question,
              style: TextStyle(
                fontFamily: WebTextStyles.faqQuestion.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Answer — clipped to 3 lines when collapsed
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                faq.answer,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: WebTextStyles.faqAnswer.fontFamily,
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              secondChild: Text(
                faq.answer,
                style: TextStyle(
                  fontFamily: WebTextStyles.faqAnswer.fontFamily,
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),

            // "Learn more" chip — only when collapsed
            if (!isExpanded) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: greenColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Learn more',
                    style: TextStyle(
                      fontSize: 12,
                      color: greenColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
