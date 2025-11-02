// lib/frontend/operator/activity_logs/components/all_activity_section.dart
import 'package:flutter/material.dart';

// Section card for viewing all activity logs
class AllActivitySection extends StatelessWidget {
  final String? focusedMachineId;

  const AllActivitySection({
    super.key,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/all-activity');
      },
      child: SizedBox(
        width: 390,
        height: 70,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            boxShadow: [
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
                    Icon(Icons.history, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "View All Activity",
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