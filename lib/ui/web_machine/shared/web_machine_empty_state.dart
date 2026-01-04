// lib/ui/machine_management/shared/shared/machine_empty_state.dart
import 'package:flutter/material.dart';

class MachineEmptyState extends StatelessWidget {
  const MachineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16),
          Text(
            'No machines found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}