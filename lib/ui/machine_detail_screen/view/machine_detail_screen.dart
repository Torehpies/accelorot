// lib/ui/machine_detail_screen/view/machine_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../widgets/machine_gauge.dart';
import '../widgets/control_card.dart';
import '../widgets/wide_action_button.dart';
import '../../../../data/models/activity_log_item.dart';
import '../widgets/activity_list.dart';
import '../../core/ui/confirmation_dialog.dart';
import '../batch_start/view/start_batch_screen.dart';

class MachineDetailScreen extends StatefulWidget {
  final MachineModel machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  bool _isBatchActive = true;

  Future<void> _handleBatchAction() async {
    if (_isBatchActive) {
      final confirmed = await showConfirmationDialog(
        context,
        'Complete Batch',
        'Are you sure you want to complete this batch?',
      );

      if (confirmed == true) {
        setState(() {
          _isBatchActive = false;
        });
      }
    } else {
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => StartBatchScreen(machineName: widget.machine.machineName),
        ),
      );
      if (result != null) {
        setState(() {
          _isBatchActive = true;
        });
      }
    }
  }

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
          widget.machine.machineName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed top section: gauges, controls, batch button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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

                // Complete Batch / Start Batch
                WideActionButton(
                  label: _isBatchActive ? 'Complete Batch' : 'Start Batch',
                  onPressed: _handleBatchAction,
                ),

                const SizedBox(height: 24),

                // Activities header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Scrollable activity list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final activities = [
                  ActivityLogItem(
                    id: '1',
                    title: 'Drum Rotated',
                    value: 'Rotated',
                    statusColor: Colors.green,
                    icon: Icons.cached,
                    description: '',
                    category: '',
                    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                    type: ActivityType.cycle,
                    operatorName: 'Berto',
                    status: null,
                  ),
                  ActivityLogItem(
                    id: '2',
                    title: 'Aerator Started',
                    value: 'Started',
                    statusColor: Colors.green,
                    icon: Icons.air,
                    description: '',
                    category: '',
                    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                    type: ActivityType.cycle,
                    operatorName: 'Berto',
                    status: null,
                  ),
                  ActivityLogItem(
                    id: '3',
                    title: 'Moisture Above Threshold',
                    value: 'High Moisture',
                    statusColor: Colors.red,
                    icon: Icons.water_drop,
                    description: '',
                    category: '',
                    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
                    type: ActivityType.alert,
                    operatorName: 'System',
                    status: null,
                  ),
                  ActivityLogItem(
                    id: '4',
                    title: 'Temperature Below Threshold',
                    value: 'Low Temp',
                    statusColor: Colors.blue,
                    icon: Icons.thermostat,
                    description: '',
                    category: '',
                    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                    type: ActivityType.alert,
                    operatorName: 'System',
                    status: null,
                  ),
                ];
                final item = activities[index];
                return ActivityListItem(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

