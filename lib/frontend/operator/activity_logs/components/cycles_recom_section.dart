// lib/frontend/operator/activity_logs/components/cycles_recom_section.dart
import 'package:flutter/material.dart';
import '../view_screens/cycles_recom_screen.dart';
import '../widgets/slide_page_route.dart';

class CyclesRecomSection extends StatelessWidget {
  final String? viewingOperatorId;

  const CyclesRecomSection({
    super.key,
    this.viewingOperatorId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(page: CyclesRecomScreen(viewingOperatorId: viewingOperatorId,)),
        );
      },
      child: SizedBox(
        width: 400,
        height: 70,
        child: Container( // Replaced Card with Container for shadow styling
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            boxShadow: [ // ⭐ ADDED: Shadow styling
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Cycles & Recommendations",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}