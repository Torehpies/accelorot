// lib/ui/machine_detail_screen/view/machine_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/statistics_providers.dart';
import '../widgets/machine_gauge.dart';
import '../widgets/control_card.dart';
import '../widgets/wide_action_button.dart';
import '../../../../data/models/activity_log_item.dart';
import '../widgets/activity_list.dart';
import '../../core/ui/confirmation_dialog.dart';
import '../add_waste/view/add_waste_screen.dart';
import '../../operator_dashboard_old/widgets/quick_actions/quick_actions_sheet.dart';
import '../../core/themes/app_theme.dart';

class MachineDetailScreen extends ConsumerStatefulWidget {
  final MachineModel machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  ConsumerState<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends ConsumerState<MachineDetailScreen> {
  bool _isBatchActive = true;

  @override
  void initState() {
    super.initState();
    _isBatchActive = widget.machine.currentBatchId != null && widget.machine.currentBatchId!.isNotEmpty;
  }

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
      // Instant batch start UI
      setState(() {
        _isBatchActive = true;
      });
    }
  }

  void _handleAddWaste() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddWasteScreen(
          machineName: widget.machine.machineName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchId = widget.machine.currentBatchId ?? '';
    final latestReadingsAsync = ref.watch(latestSensorReadingsProvider(batchId));

    double? tempVal;
    double? moistVal;
    double? oxyVal;
    String lastUpdatedText = 'No data available';

    latestReadingsAsync.whenData((data) {
      if (data != null) {
        tempVal = data['temperature'] as double?;
        moistVal = data['moisture'] as double?;
        oxyVal = data['oxygen'] as double?;
        
        final timestamp = data['timestamp'] as DateTime?;
        if (timestamp != null) {
          final timeStr = DateFormat('h:mm a').format(timestamp);
          final now = DateTime.now();
          if (timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day) {
            lastUpdatedText = 'Updated $timeStr';
          } else {
            final dateStr = DateFormat('MMM d').format(timestamp);
            lastUpdatedText = 'Updated $dateStr, $timeStr';
          }
        }
      }
    });

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
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SENSOR READINGS',
                            style: TextStyle(
                              color: Color(0xFF789CA4), // Blue-grey color matching design
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lastUpdatedText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF789CA4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      latestReadingsAsync.when(
                        data: (_) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: MachineGauge(
                                      value: tempVal,
                                      min: 0,
                                      max: 100, // Matches stats module maxScale
                                      label: 'Temperature',
                                      unit: '°',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (tempVal != null && tempVal! > 70) ? 'High' : (tempVal != null && tempVal! < 55 ? 'Low' : 'Normal'),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: MachineGauge(
                                      value: moistVal,
                                      min: 0,
                                      max: 100, // Matches stats module maxScale
                                      label: 'Moisture',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (moistVal != null && moistVal! > 60) ? 'High' : (moistVal != null && moistVal! < 40 ? 'Low' : 'Normal'),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: MachineGauge(
                                      value: oxyVal,
                                      min: 0,
                                      max: 5000, // Updated to match stats module maxScale
                                      label: 'PPM',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (oxyVal != null && oxyVal! > 2500) ? 'High' : (oxyVal != null && oxyVal! < 1500 ? 'Low' : 'Normal'),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => const SizedBox(
                          height: 150,
                          child: Center(child: Text('Error loading sensor data')),
                        ),
                      ),
                    ],
                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => QuickActionsSheet(
              preSelectedMachineId: widget.machine.machineId,
              preSelectedBatchId: widget.machine.currentBatchId,
              onAddWaste: _handleAddWaste,
            ),
          );
        },
        backgroundColor: AppColors.green100,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
