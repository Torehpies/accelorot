// lib/ui/activity_logs/widgets/navigation_section_card.dart
import 'package:flutter/material.dart';

/// Reusable navigation card for simple tap-to-navigate sections
class NavigationSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String? focusedMachineId;

  const NavigationSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      child: SizedBox(
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
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.teal,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
