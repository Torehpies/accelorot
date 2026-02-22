// lib/ui/operator_dashboard/widgets/operator_machine_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/providers/statistics_providers.dart';

class OperatorMachineCard extends ConsumerWidget {
  final MachineModel machine;
  final VoidCallback onTap;

  const OperatorMachineCard({
    super.key,
    required this.machine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (machine.currentBatchId == null) {
      return _buildCard(
        context: context,
        borderColor: const Color(0xFFCED4DA), // Grey border
        icon: Icons.settings,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFFA8B5C0), // Grey circle
        label: 'Empty',
        labelColor: const Color(0xFFA8B5C0),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: '0',
        subtitle: 'No Active Batch',
      );
    }

    // 2. Fetch active batch to calculate days
    final batchAsync = ref.watch(activeBatchForMachineProvider(machine.machineId));
    
    int days = 0;
    batchAsync.whenData((batch) {
      if (batch != null) {
         final diff = DateTime.now().difference(batch.createdAt).inDays + 1;
         days = diff > 0 ? diff : 1; // Minimum Day 1
      }
    });

    // 3. Listen to latest sensor readings to check for Alert state
    final readingsAsync = ref.watch(latestSensorReadingsProvider(machine.currentBatchId!));
    
    bool isAlert = false;
    String alertLabel = 'Alert';

    readingsAsync.whenData((readings) {
      if (readings != null) {
        final temp = readings['temperature'];
        final moist = readings['moisture'];
        final oxy = readings['oxygen'];

        if (temp != null && (temp < 55 || temp > 70)) {
          isAlert = true;
          alertLabel = 'High Temperature';
        } else if (moist != null && (moist < 40 || moist > 60)) {
          isAlert = true;
          alertLabel = 'Moisture Alert';
        } else if (oxy != null && (oxy < 1500 || oxy > 2500)) {
          isAlert = true;
          alertLabel = 'Oxygen Alert';
        }
      }
    });

    // 4. Determine Design (Alert vs Running vs Rest)
    if (isAlert) {
      return _buildCard(
        context: context,
        borderColor: const Color(0xFFFF4D4F), // Red border
        icon: Icons.thermostat,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFFFF4D4F), // Red circle
        label: alertLabel, 
        labelColor: const Color(0xFFFF4D4F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: ${machine.currentBatchId?.substring(0, 5) ?? ''}...',
      );
    } else if (machine.drumActive) {
      return _buildCard(
        context: context,
        borderColor: const Color(0xFF2ECA7F), // Green border
        icon: Icons.settings,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF2ECA7F), // Green circle
        label: 'Running',
        labelColor: const Color(0xFF2ECA7F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: ${machine.currentBatchId?.substring(0, 5) ?? ''}...',
      );
    } else {
      // Rest
      return _buildCard(
        context: context,
        borderColor: const Color(0xFF2ECA7F), // Green border
        icon: Icons.settings,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF2ECA7F), // Green circle
        label: 'Rest',
        labelColor: const Color(0xFF2ECA7F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: ${machine.currentBatchId?.substring(0, 5) ?? ''}...',
      );
    }
  }

  Widget _buildCard({
    required BuildContext context,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required Color labelColor,
    required String daysLabel,
    required Color daysColor,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Left Icon Bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Middle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    machine.machineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0AEC0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),

            // Right Days Display
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  daysLabel,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: daysColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Araw',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA0AEC0),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
