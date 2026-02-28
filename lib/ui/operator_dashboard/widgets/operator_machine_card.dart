// lib/ui/operator_dashboard/widgets/operator_machine_card.dart

import 'dart:async';
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
        labels: ['Empty'],
        labelColor: const Color(0xFFA8B5C0),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: '0',
        subtitle: 'No Active Batch',
      );
    }

    // 2. Fetch active batch to calculate days and get name
    final batchAsync = ref.watch(activeBatchForMachineProvider(machine.machineId));
    
    int days = 0;
    String batchName = machine.currentBatchId != null ? '${machine.currentBatchId!.substring(0, 5)}...' : '';

     batchAsync.whenData((batch) {
      if (batch != null) {
         final diff = DateTime.now().difference(batch.createdAt).inDays + 1;
         days = diff > 0 ? diff : 1; // Minimum Day 1
         batchName = batch.displayName; // Retrieve actual readable name
      }
    });

    // 3. Listen to latest sensor readings to check for Alert state
    final readingsAsync = ref.watch(latestSensorReadingsProvider(machine.currentBatchId!));
    
    List<String> activeAlerts = [];

    readingsAsync.whenData((readings) {
      if (readings != null) {
        final temp = readings['temperature'] as double?;
        final moist = readings['moisture'] as double?;
        final oxy = readings['oxygen'] as double?;

        if (temp != null && temp > 70) activeAlerts.add('High Temperature');
        if (temp != null && temp < 55) activeAlerts.add('Low Temperature');
        
        if (moist != null && moist > 60) activeAlerts.add('High Moisture');
        if (moist != null && moist < 40) activeAlerts.add('Low Moisture');
        
        if (oxy != null && oxy > 2500) activeAlerts.add('High PPM');
        if (oxy != null && oxy < 1500) activeAlerts.add('Low PPM');
      }
    });

    bool isAlert = activeAlerts.isNotEmpty;

    // 4. Determine Design (Alert vs Running vs Rest)
    if (isAlert) {
      return _buildCard(
        context: context,
        borderColor: const Color(0xFFFF4D4F), // Red border
        icon: Icons.thermostat,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFFFF4D4F), // Red circle
        label: activeAlerts.first, 
        labels: activeAlerts,
        labelColor: const Color(0xFFFF4D4F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: $batchName',
      );
    } else if (machine.drumActive) {
      return _buildCard(
        context: context,
        borderColor: const Color(0xFF2ECA7F), // Green border
        icon: Icons.settings,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF2ECA7F), // Green circle
        label: 'Running',
        labels: ['Running'],
        labelColor: const Color(0xFF2ECA7F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: $batchName',
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
        labels: ['Rest'],
        labelColor: const Color(0xFF2ECA7F),
        daysColor: const Color(0xFF2C3E50),
        daysLabel: days.toString(),
        subtitle: 'Batch: $batchName',
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
    required List<String> labels,
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
                  AnimatedAlertLabel(
                    labels: labels,
                    textStyle: TextStyle(
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

class AnimatedAlertLabel extends StatefulWidget {
  final List<String> labels;
  final TextStyle textStyle;

  const AnimatedAlertLabel({
    super.key,
    required this.labels,
    required this.textStyle,
  });

  @override
  State<AnimatedAlertLabel> createState() => _AnimatedAlertLabelState();
}

class _AnimatedAlertLabelState extends State<AnimatedAlertLabel> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.labels.length > 1) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedAlertLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.labels.length > 1 && oldWidget.labels.length <= 1) {
      _startTimer();
    } else if (widget.labels.length <= 1) {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && widget.labels.isNotEmpty) {
        setState(() {
          _index = (_index + 1) % widget.labels.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure index is valid in case labels list shortened
    final safeIndex = _index % widget.labels.length;
    final currentLabel = widget.labels[safeIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        currentLabel,
        key: ValueKey<String>(currentLabel),
        style: widget.textStyle,
      ),
    );
  }
}

