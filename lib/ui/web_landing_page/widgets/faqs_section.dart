import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ADDED
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _expandedIndex;

  // EMAIL LAUNCHING LOGIC (copied from ContactSection)
  Future<void> _launchEmail() async {
    final email = 'accelorot.management@gmail.com';
    final subject = 'Inquiry from Accel-O-Rot Website';

    // Try Gmail compose URL first
    final gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject'
    );

    if (!await launchUrl(gmailUri)) {
      // Fallback to standard mailto
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
    // ... (existing FAQ items unchanged) ...
    FaqItem(
      question: 'What is Accel-O-Rot?',
      answer: 'Accel-O-Rot is an IoT-enabled smart rotary drum composting system designed to accelerate the decomposition of organic waste. It uses sensors, aeration, and moisture regulation to optimize the composting process, making it faster and more efficient than traditional methods.',
    ),
    FaqItem(
      question: 'How does the system accelerate composting?',
      answer: 'The system uses a rotary drum to continuously mix materials for better aeration and homogeneity. It monitors critical environmental parameters—temperature, moisture, and air quality—and uses automated systems to maintain optimal conditions, which can lead to mature compost in as little as 14 days.',
    ),
    FaqItem(
      question: 'What types of waste can I put in the Accel-O-Rot?',
      answer: 'The system is designed for organic, biodegradable waste. Users can add a mix of "greens" (e.g., food scraps) and "browns" (e.g., dry leaves) to start the decomposition process.',
    ),
    FaqItem(
      question: 'What are the main benefits for a community or institution?',
      answer: 'Accel-O-Rot boosts the ability of barangays and local government units to manage organic waste, simultaneously lowering hauling expenses and reliance on landfills. It greatly lowers methane emissions, unpleasant smells, leachate pollution, and habitats for disease-carrying pests such as flies and rodents—enhancing public health while producing nutrient-dense compost for city gardening and municipal landscaping. For universities and schools, the system reduces waste disposal expenses by transforming cafeteria leftovers and garden waste into compost for campus agricultural initiatives, while also acting as a hands-on learning resource that improves students insights into organic waste management, greenhouse gas mitigation, and intelligent sustainable technologies',
    ),
    FaqItem(
      question: 'What types of organic waste can be processed?',
      answer: 'Accel-O-Rot processes biodegradable waste including kitchen waste like greens and dry leaves for browns. The system guides users through its mobile application to balance these inputs at the optimal carbon-to-nitrogen ratio of 25:1 to 30:1 for rapid, odor-free decomposition, significantly accelerating microbial activity and ensuring uniform compost maturity within 14 days.',
    ),
    FaqItem(
      question: 'How does the system ensure the final product is safe to use as fertilizer?',
      answer: 'The system design follows the Philippine National Standard for Compost (PNS/BAFS PA 1:2019). By monitoring temperature to ensure it reaches the necessary high-heat (thermophilic) phase, the system helps kill harmful pathogens, making the resulting compost safe for urban agriculture and gardening.',
    ),
  ];

  void _toggleCard(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 1400 ? 120.0 : 24.0;
    final baseContactStyle = TextStyle(
      fontFamily: WebTextStyles.faqAnswer.fontFamily,
      fontSize: 16,
      color: Colors.black.withValues(alpha: 0.7),
      height: 1.5,
    );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Frequently Asked Questions',
                style: WebTextStyles.faqSectionTitle.copyWith(
                  fontSize: width > 600 ? 32 : 26,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Clear, concise answers to help you understand how Accel-O-Rot works — from setup to safety and performance.',
                style: WebTextStyles.faqSectionSubtitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),

              // FAQ cards
              for (int i = 0; i < _faqItems.length; i++)
                _FaqCard(
                  faq: _faqItems[i],
                  isExpanded: _expandedIndex == i,
                  onToggle: () => _toggleCard(i),
                ),
              
              // CONTACT SECTION WITH CLICKABLE EMAIL
              SizedBox(height: AppSpacing.xl),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 0,
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
                            color: const Color(0xFF1A73E8), // Professional blue
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF1A73E8),
                            decorationThickness: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '.',
                      style: baseContactStyle,
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

// ... (FaqItem and _FaqCard classes remain unchanged) ...
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

class _FaqCard extends StatelessWidget {
  final FaqItem faq;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FaqCard({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Text(
              faq.question,
              style: TextStyle(
                fontFamily: WebTextStyles.faqQuestion.fontFamily,
                fontSize: WebTextStyles.faqQuestion.fontSize,
                fontWeight: isExpanded ? FontWeight.w600 : WebTextStyles.faqQuestion.fontWeight,
                color: WebTextStyles.faqQuestion.color,
              ),
            ),
            trailing: RotationTransition(
              turns: AlwaysStoppedAnimation(isExpanded ? 0.5 : 0.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 24,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Text(
                faq.answer,
                style: WebTextStyles.faqAnswer,
              ),
            ),
        ],
      ),
    );
  }
}