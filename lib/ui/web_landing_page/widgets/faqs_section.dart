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
      answer: 'Accel-O-Rot is an IoT-enabled smart rotary drum composting system designed to accelerate the decomposition of organic waste. It uses sensors, aeration, and moisture regulation to optimize the composting process, making it faster and more efficient than traditional methods.',
      icon: Icons.eco_outlined,
    ),
    FaqItem(
      question: 'How does the system accelerate composting?',
      answer: 'The system uses a rotary drum to continuously mix materials for better aeration and homogeneity. It monitors critical environmental parameters—temperature, moisture, and air quality—and uses automated systems to maintain optimal conditions, which can lead to mature compost in as little as 14 days.',
      icon: Icons.speed_outlined,
    ),
    FaqItem(
      question: 'What types of waste can I put in the Accel-O-Rot?',
      answer: 'The system is designed for organic, biodegradable waste. Users can add a mix of "greens" (e.g., food scraps) and "browns" (e.g., dry leaves) to start the decomposition process.',
      icon: Icons.delete_outline,
    ),
    FaqItem(
      question: 'What are the main benefits for a community or institution?',
      answer: 'Accel-O-Rot boosts the ability of barangays and local government units to manage organic waste, simultaneously lowering hauling expenses and reliance on landfills. It greatly lowers methane emissions, unpleasant smells, leachate pollution, and habitats for disease-carrying pests such as flies and rodents—enhancing public health while producing nutrient-dense compost for city gardening and municipal landscaping. For universities and schools, the system reduces waste disposal expenses by transforming cafeteria leftovers and garden waste into compost for campus agricultural initiatives, while also acting as a hands-on learning resource that improves students insights into organic waste management, greenhouse gas mitigation, and intelligent sustainable technologies',
      icon: Icons.groups_outlined,
    ),
    FaqItem(
      question: 'What types of organic waste can be processed?',
      answer: 'Accel-O-Rot processes biodegradable waste including kitchen waste like greens and dry leaves for browns. The system guides users through its mobile application to balance these inputs at the optimal carbon-to-nitrogen ratio of 25:1 to 30:1 for rapid, odor-free decomposition, significantly accelerating microbial activity and ensuring uniform compost maturity within 14 days.',
      icon: Icons.recycling_outlined,
    ),
    FaqItem(
      question: 'How does the system ensure the final product is safe to use as fertilizer?',
      answer: 'The system design follows the Philippine National Standard for Compost (PNS/BAFS PA 1:2019). By monitoring temperature to ensure it reaches the necessary high-heat (thermophilic) phase, the system helps kill harmful pathogens, making the resulting compost safe for urban agriculture and gardening.',
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
    final horizontalPadding = width > 1400 ? 120.0 : 24.0;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1200;
    
    final greenColor = const Color(0xFF2E7D32);
    final baseContactStyle = TextStyle(
      fontFamily: WebTextStyles.faqAnswer.fontFamily,
      fontSize: 16,
      color: Colors.black.withValues(alpha: 0.7),
      height: 1.5,
    );

    return Container(
      color: const Color(0xFAFAFAFA),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontFamily: WebTextStyles.faqSectionTitle.fontFamily,
                  fontSize: width > 600 ? 40 : 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Here\'s what other people are finding most useful right now:',
                style: TextStyle(
                  fontFamily: WebTextStyles.faqSectionSubtitle.fontFamily,
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),

              // Grid layout - 3 columns on desktop, 2 on tablet, 1 on mobile
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isMobile ? 2.2 : isTablet ? 1.6 : 1.4,
                ),
                itemCount: _faqItems.length,
                itemBuilder: (context, index) {
                  return _FaqCard(
                    faq: _faqItems[index],
                    isExpanded: _expandedIndex == index,
                    onToggle: () => _toggleCard(index),
                    greenColor: greenColor,
                  );
                },
              ),

              // Contact Section
              SizedBox(height: AppSpacing.xl * 1.5),
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
                            color: const Color(0xFF1A73E8),
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
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: greenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  faq.icon,
                  size: 20,
                  color: greenColor,
                ),
              ),
              const SizedBox(height: 16),
              // Question title
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
              // Answer preview or full text
              Expanded(
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontFamily: WebTextStyles.faqAnswer.fontFamily,
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
              ),
              // Learn more indicator
              if (!isExpanded)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
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
          ),
        ),
      ),
    );
  }
}