import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _expandedIndex;

  final List<FaqItem> _faqItems = const [
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
      question: 'How does the system\'s performance compare to traditional composting?',
      answer: 'Unlike traditional methods that are often slow and labor-intensive, Accel-O-Rot uses automation and sensors to produce mature compost much faster—typically in 14 days.',
    ),
    FaqItem(
      question: 'How fast does Accel-O-Rot produce compost compared to traditional methods?',
      answer: 'The Accel-O-Rot produces mature compost in 14 days using a scaled-down rotary drum in Traditional composting methods, though environmentally friendly, often face challenges such as inconsistent decomposition, long processing times, and dependence on manual labor.',
    ),
    FaqItem(
      question: 'How does it handle potential health risks like pathogens?',
      answer: 'While the system does not have direct pathogen sensors, it minimizes risk by strictly monitoring and maintaining the temperature. Following established standards, keeping the compost at high temperatures (typically ≥55°C) for a specific duration helps eliminate harmful microorganisms.',
    ),
    FaqItem(
      question: 'What are the main benefits for a community or institution?',
      answer: 'Accel-O-Rot boosts the ability of barangays and local government units to manage organic waste, simultaneously lowering hauling expenses and reliance on landfills. It greatly lowers methane emissions, unpleasant smells, leachate pollution, and habitats for disease-carrying pests such as flies and rodents—enhancing public health while producing nutrient-dense compost for city gardening and municipal landscaping. For universities and schools, the system reduces waste disposal expenses by transforming cafeteria leftovers and garden waste into compost for campus agricultural initiatives, while also acting as a hands-on learning resource that improves students insights into organic waste management, greenhouse gas mitigation, and intelligent sustainable technologies',    ),
    FaqItem(
      question: 'How does the "Drum Controller" feature work for the operator?',
      answer: 'The Drum Controller enables efficient batch monitoring. Operators may select a specific machine to view batch details,  including Batch ID, start date, and days elapsed, and  click  “Start” to begin drum rotation.',
    ),
    FaqItem(
      question: 'What types of organic waste can be processed?',
      answer: 'Accel-O-Rot processes biodegradable waste  including kitchen waste like greens and dry leaves for browns. The system guides users through its mobile application to balance these inputs at the optimal carbon-to-nitrogen ratio of 25:1 to 30:1 for rapid, odor-free decomposition, significantly accelerating microbial activity and ensuring uniform compost maturity within 14 days.',
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

              // ✅ FIXED: Use Column instead of AnimatedList
              for (int i = 0; i < _faqItems.length; i++)
                _FaqCard(
                  faq: _faqItems[i],
                  isExpanded: _expandedIndex == i,
                  onToggle: () => _toggleCard(i),
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
                color: Colors.black.withOpacity(0.7),
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