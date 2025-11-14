// lib/frontend/operator/dashboard/cycles/widgets/drum_input_fields.dart

import 'package:flutter/material.dart';

class DrumInputFields extends StatelessWidget {
  final String selectedCycle;
  final String selectedPeriod;
  final ValueChanged<String?> onCycleChanged;
  final ValueChanged<String?> onPeriodChanged;
  final bool isLocked; // Lock when running or paused

  const DrumInputFields({
    super.key,
    required this.selectedCycle,
    required this.selectedPeriod,
    required this.onCycleChanged,
    required this.onPeriodChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Cycles',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabled: !isLocked,
            ),
            initialValue: selectedCycle,
            onChanged: isLocked ? null : onCycleChanged,
            items: const [
              DropdownMenuItem(value: "50", child: Text("50")),
              DropdownMenuItem(value: "100", child: Text("100")),
              DropdownMenuItem(value: "150", child: Text("150")),
              DropdownMenuItem(value: "200", child: Text("200")),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Period',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabled: !isLocked,
            ),
            initialValue: selectedPeriod,
            onChanged: isLocked ? null : onPeriodChanged,
            items: const [
              DropdownMenuItem(value: '15 minutes', child: Text('15 min')),
              DropdownMenuItem(value: '30 minutes', child: Text('30 min')),
              DropdownMenuItem(value: '1 hour', child: Text('1 hour')),
            ],
          ),
        ),
      ],
    );
  }
}
