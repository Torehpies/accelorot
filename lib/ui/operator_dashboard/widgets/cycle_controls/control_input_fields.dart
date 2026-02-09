// lib/frontend/operator/dashboard/cycles/widgets/drum_input_fields.dart

import 'package:flutter/material.dart';

class ControlInputFields extends StatelessWidget {
  final String selectedCycle;
  final String selectedPeriod;
  final ValueChanged<String?> onCycleChanged;
  final ValueChanged<String?> onPeriodChanged;
  final bool isLocked; // Lock when running or paused

  const ControlInputFields({
    super.key,
    required this.selectedCycle,
    required this.selectedPeriod,
    required this.onCycleChanged,
    required this.onPeriodChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define valid values
    final validCycles = List.generate(24, (index) => '${index + 1}');
    final validPeriods = ['10 minutes', '15 minutes', '20 minutes', '25 minutes', '30 minutes'];
    
    // Validate current selections
    final currentCycle = validCycles.contains(selectedCycle) ? selectedCycle : '1';
    final currentPeriod = validPeriods.contains(selectedPeriod) ? selectedPeriod : '10 minutes';
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Period (Runtime)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            initialValue: currentPeriod,
            onChanged: isLocked ? null : onPeriodChanged,
            items: validPeriods
                .map((period) => DropdownMenuItem(
                      value: period,
                      child: Text(period.replaceAll(' minutes', ' min')),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Cycles per Day',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            initialValue: currentCycle,
            onChanged: isLocked ? null : onCycleChanged,
            items: validCycles
                .map((cycle) => DropdownMenuItem(
                      value: cycle,
                      child: Text(cycle),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}