// lib/ui/machine_detail_screen/view/machine_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/statistics_providers.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/substrate_providers.dart';
import '../../../data/models/substrate.dart';
import '../widgets/machine_gauge.dart';
import '../widgets/drum_control.dart';
import '../widgets/aerator_control.dart';
import '../widgets/sensor_trend_view.dart';
import '../widgets/wide_action_button.dart';
import '../../admin_dashboard/web_widgets/recent_activities_table.dart';
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
  // We no longer need local _isBatchActive state because the stream handles it.
  String _selectedSensorTab = 'All';

  Future<void> _handleBatchAction(MachineModel currentMachine, bool isBatchActive) async {
    if (isBatchActive) {
      final confirmed = await showConfirmationDialog(
        context,
        'Complete Batch',
        'Are you sure you want to complete this batch?',
      );

      if (!mounted) return;

      if (confirmed == true) {
        if (currentMachine.currentBatchId?.isNotEmpty == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          try {
            await ref.read(batchRepositoryProvider).completeBatch(
              currentMachine.currentBatchId!,
              finalWeight: 0, // Placeholder
            );
            ref.invalidate(activeBatchForMachineProvider(currentMachine.machineId));
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
          } catch (e) {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to complete batch: $e')));
            return;
          }
        }
      }
    } else {
      // Instant batch start UI
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception('User not logged in');

        final batchRepo = ref.read(batchRepositoryProvider);
        
        // Get the historical max batch index
        final allBatches = await batchRepo.getBatchesForMachines([currentMachine.machineId]);
        int maxIndex = 0;
        for (final b in allBatches) {
          if (b.batchNumber > maxIndex) maxIndex = b.batchNumber;
        }
        final newBatchNumber = maxIndex + 1;
        final newBatchName = 'Batch $newBatchNumber';

        await batchRepo.createBatch(
          userId,
          currentMachine.machineId,
          newBatchNumber,
          batchName: newBatchName,
        );

        ref.invalidate(activeBatchForMachineProvider(currentMachine.machineId));

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start batch: $e')),
        );
      }
    }
  }

  Future<void> _handleAddWaste(MachineModel currentMachine) async {
    // Capture provider refs BEFORE the async navigation gap,
    // because the State may be unmounted while AddWasteScreen is showing.
    final substrateRepo = ref.read(substrateRepositoryProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final operatorName = FirebaseAuth.instance.currentUser?.displayName ?? 'Operator';

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => AddWasteScreen(
          machineName: currentMachine.machineName,
        ),
      ),
    );

    debugPrint('🔍 AddWaste result: $result');

    if (result == null) return;
    if (userId == null) {
      debugPrint('❌ User not logged in');
      return;
    }

    debugPrint('✅ Result received, submitting to database...');

    try {
      final double quantity = (result['quantity'] as num).toDouble();

      final Set<String> substratesSet = result['substrates'] as Set<String>;
      final String substrateLabels = substratesSet.join(', ');

      final Set<String> additivesSet = result['additives'] as Set<String>;
      final String additivesLabels = additivesSet.join(', ');

      final descriptionBuffer = StringBuffer();
      if (substratesSet.isNotEmpty) {
        descriptionBuffer.writeln('Substrates: $substrateLabels');
      }
      if (additivesSet.isNotEmpty) {
        descriptionBuffer.writeln('Additives: $additivesLabels');
      }

      final request = CreateSubstrateRequest(
        category: 'Compost',
        plantType: 'Added Substrates',
        plantTypeLabel: 'Added Substrates',
        quantity: quantity,
        description: descriptionBuffer.toString().trim(),
        machineId: currentMachine.machineId,
        operatorName: operatorName,
        userId: userId,
      );

      debugPrint('🔍 Calling addSubstrate with: ${request.toFirestore()}');
      await substrateRepo.addSubstrate(request);
      debugPrint('✅ addSubstrate completed successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waste entry added successfully!')),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to add waste: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add waste: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to real-time machine updates to correctly reflect batch start/completion
    final currentMachineAsync = ref.watch(machineStreamProvider(widget.machine.machineId));
    final currentMachine = currentMachineAsync.value ?? widget.machine;
    final isBatchActive = currentMachine.currentBatchId?.isNotEmpty == true;

    final batchId = currentMachine.currentBatchId ?? '';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentMachine.machineName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (currentMachine.currentBatchId?.isNotEmpty == true)
              ref.watch(activeBatchForMachineProvider(currentMachine.machineId)).when(
                data: (batch) {
                  if (batch == null) return const SizedBox.shrink();
                  final dateStr = DateFormat('MM/dd/yy').format(batch.createdAt);
                  final daysPassed = DateTime.now().difference(batch.createdAt).inDays + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '${batch.displayName} | $dateStr | Day $daysPassed',
                      style: const TextStyle(
                        color: Color(0xFF547589),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
          ],
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
                      const SizedBox(height: 16),
                      // Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Temp', 'Moisture', 'PPM'].map((tab) {
                            final isSelected = _selectedSensorTab == tab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(tab),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedSensorTab = tab);
                                  }
                                },
                                selectedColor: const Color(0xFF3B717B),
                                backgroundColor: const Color(0xFFF0F4F7),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF789CA4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF3B717B) : Colors.transparent,
                                  ),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Content
                      if (_selectedSensorTab == 'All')
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
                        )
                      else if (_selectedSensorTab == 'Temp')
                        SizedBox(
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, right: 16),
                            child: SensorTrendView(
                              batchId: batchId,
                              sensorType: SensorType.temperature,
                            ),
                          ),
                        )
                      else if (_selectedSensorTab == 'Moisture')
                        SizedBox(
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, right: 16),
                            child: SensorTrendView(
                              batchId: batchId,
                              sensorType: SensorType.moisture,
                            ),
                          ),
                        )
                      else if (_selectedSensorTab == 'PPM')
                        SizedBox(
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, right: 16),
                            child: SensorTrendView(
                              batchId: batchId,
                              sensorType: SensorType.oxygen,
                            ),
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
                      child: DrumControl(machine: currentMachine),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AeratorControl(machine: currentMachine),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Complete Batch / Start Batch
                WideActionButton(
                  label: isBatchActive ? 'Complete Batch' : 'Start Batch',
                  onPressed: () => _handleBatchAction(currentMachine, isBatchActive),
                ),

                const SizedBox(height: 24),


              ],
            ),
          ),

          // Scrollable activity list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RecentActivitiesTable(
                machineId: currentMachine.machineId,
                hideHeader: true,
                isCondensed: true,
              ),
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
              preSelectedMachineId: currentMachine.machineId,
              preSelectedBatchId: currentMachine.currentBatchId,
              onAddWaste: () {
                if (!isBatchActive) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Start a batch first before adding waste.')),
                  );
                  return;
                }
                _handleAddWaste(currentMachine);
              },
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
