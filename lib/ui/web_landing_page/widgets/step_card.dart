// lib/ui/landing_page/widgets/step_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../models/step_model.dart';

class StepCard extends StatelessWidget {
  final StepModel step;

  const StepCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(38, 0, 0, 0), // 15% opacity
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 240, 240, 240),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CIRCLE BACKGROUND FOR STEP NUMBER
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 204, 251, 241),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 118, 230, 207),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(51, 0, 0, 0), // 20% opacity
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${step.number}',
                style: WebTextStyles.stepNumber.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF28A85A),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // STEP TITLE - BELOW THE CIRCLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              style: WebTextStyles.stepCardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // STEP DESCRIPTION - MULTI-LINE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getFirstLine(step.description),
                    textAlign: TextAlign.center,
                    style: WebTextStyles.stepCardDescription.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSecondLine(step.description),
                    textAlign: TextAlign.center,
                    style: WebTextStyles.stepCardDescription.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getThirdLine(step.description),
                    textAlign: TextAlign.center,
                    style: WebTextStyles.stepCardDescription.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions to split description into lines
  String _getFirstLine(String description) {
    final words = description.split(' ');
    if (words.length >= 3) {
      return words.sublist(0, 3).join(' ');
    }
    return description;
  }

  String _getSecondLine(String description) {
    final words = description.split(' ');
    if (words.length >= 6) {
      return words.sublist(3, 6).join(' ');
    } else if (words.length > 3) {
      return words.sublist(3).join(' ');
    }
    return '';
  }

  String _getThirdLine(String description) {
    final words = description.split(' ');
    if (words.length >= 7) {
      return words.sublist(6).join(' ');
    }
    return '';
  }
}