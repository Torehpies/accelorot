// lib/ui/machine_detail_screen/view/machine_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../widgets/machine_gauge.dart';
import '../widgets/control_card.dart';
import '../widgets/wide_action_button.dart';


class MachineDetailScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          machine.machineName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: MachineGauge(
                      value: 36,
                      min: 0,
                      max: 100,
                      label: 'Temperature',
                      unit: '°',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: MachineGauge(
                      value: 55,
                      min: 0,
                      max: 100,
                      label: 'Moisture',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: MachineGauge(
                      value: 500,
                      min: 0,
                      max: 1000,
                      label: 'PPM',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Control Cards
            Row(
              children: [
                Expanded(
                  child: ControlCard(
                    title: 'Drum Uptime',
                    timerValue: '00:00',
                    buttonLabel: 'Start Drum',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ControlCard(
                    title: 'Aerator Uptime',
                    timerValue: '00:00',
                    buttonLabel: 'Start Aerator',
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Complete Batch 
            WideActionButton(
              label: 'Complete Batch',
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 60,
        child: ColoredBox(color: Color(0xFFF5F5F5)),
      ),
    );
  }
}