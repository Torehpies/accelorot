import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/statistics_providers.dart';
import '../widgets/temperature_statistic_card.dart';
import '../widgets/moisture_statistic_card.dart';
import '../widgets/oxygen_statistic_card.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/selected_machine_provider.dart'; 
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';

class WebStatisticsScreen extends ConsumerStatefulWidget {
  final String? focusedMachineId;

  const WebStatisticsScreen({super.key, this.focusedMachineId});

  @override
  ConsumerState<WebStatisticsScreen> createState() => _WebStatisticsScreenState();
}

class _WebStatisticsScreenState extends ConsumerState<WebStatisticsScreen> {
  String? selectedBatch;

  // Sample batches for UI demonstration
  final List<String> sampleBatches = [
    'Batch A',
    'Batch B',
    'Batch C',
    'Batch D',
  ];

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: const Center(
              child: Text('No team assigned. Please contact your administrator.'),
            ),
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: machinesAsync.when(
            data: (machines) {
              final activeMachines = machines
                  .where((m) => !m.isArchived && m.id != null)
                  .toList();
              
              if (activeMachines.isEmpty) {
                return const Center(
                  child: Text('No active machines available'),
                );
              }

              // Initialize selected machine if needed
              final selectedMachineId = ref.watch(selectedMachineIdProvider);
              if (selectedMachineId.isEmpty || 
                  !activeMachines.any((m) => m.id == selectedMachineId)) {
                final initialId = widget.focusedMachineId ?? activeMachines.first.id!;
                Future.microtask(() {
                  ref.read(selectedMachineIdProvider.notifier).setMachine(initialId);
                });
                return const Center(child: CircularProgressIndicator());
              }

              // Initialize batch if needed
              if (selectedBatch == null) {
                Future.microtask(() {
                  setState(() {
                    selectedBatch = sampleBatches.first;
                  });
                });
              }

              return RefreshIndicator(
                onRefresh: () => _handleRefresh(ref, selectedMachineId),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(activeMachines, ref),
                      const SizedBox(height: 32),
                      _buildStatisticsCards(),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading machines',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(machinesStreamProvider(teamId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(List<MachineModel> machines, WidgetRef ref) {
    return Row(
      children: [
        // Machine Selector
        Expanded(
          child: _buildMachineSelector(machines, ref),
        ),
        const SizedBox(width: 16),
        
        // Batch Selector
        Expanded(
          child: _buildBatchSelector(),
        ),
      ],
    );
  }

  Widget _buildMachineSelector(List<MachineModel> machines, WidgetRef ref) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMachineId,
          hint: const Text('Select a machine'),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          items: machines.map((machine) {
            return DropdownMenuItem(
              value: machine.id!,
              child: Text(machine.machineName),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(selectedMachineIdProvider.notifier).setMachine(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBatchSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedBatch,
          hint: const Text('Select a batch'),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          items: sampleBatches.map((batch) {
            return DropdownMenuItem(
              value: batch,
              child: Text(batch),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedBatch = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Sample data for demonstration
        final sampleHourlyReadings = [40.0, 55.0, 45.0, 65.0, 50.0, 70.0];

        final cards = [
          TemperatureStatisticCard(
            currentTemperature: 1300.0,
            hourlyReadings: sampleHourlyReadings,
            lastUpdated: DateTime.now(),
          ),
          MoistureStatisticCard(
            currentMoisture: 28.0,
            hourlyReadings: sampleHourlyReadings,
            lastUpdated: DateTime.now(),
          ),
          OxygenStatisticCard(
            currentOxygen: 550.0,
            hourlyReadings: sampleHourlyReadings,
            lastUpdated: DateTime.now(),
          ),
        ];

        // Responsive layout
        if (width < 700) {
          // Mobile: Single column
          return Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: card,
                    ))
                .toList(),
          );
        } else if (width < 1100) {
          // Tablet: 2 columns
          return Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[1]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[2]),
                    const Expanded(child: SizedBox()), // Empty space
                  ],
                ),
              ),
            ],
          );
        } else {
          // Desktop: 3 columns
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 20),
                Expanded(child: cards[1]),
                const SizedBox(width: 20),
                Expanded(child: cards[2]),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> _handleRefresh(WidgetRef ref, String machineId) async {
    ref.invalidate(temperatureDataProvider(machineId));
    ref.invalidate(moistureDataProvider(machineId));
    ref.invalidate(oxygenDataProvider(machineId));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
