import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/temperature_statistic_card.dart';
import 'widgets/moisture_statistic_card.dart';
import 'widgets/oxygen_statistic_card.dart';
import '../../data/providers/machine_providers.dart';
import '../../data/providers/selected_machine_provider.dart'; 
import '../../data/providers/statistics_providers.dart';
import '../../data/models/machine_model.dart';
import '../../services/sess_service.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  final String? focusedMachineId;

  const StatisticsScreen({super.key, this.focusedMachineId});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
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
             appBar: kIsWeb
          ? null 
          : MobileHeader(title: 'Statistics'),
          
            body: const Center(
              child: Text('No team assigned. Please contact your administrator.'),
            ),
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: kIsWeb ? null : MobileHeader(title: 'Statistics'),
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
                // Use focusedMachineId or first machine
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSelectors(activeMachines),
                    const SizedBox(height: 20),
                    _buildStatisticsCards(selectedMachineId),
                  ],
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
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
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

  Widget _buildSelectors(List<MachineModel> activeMachines) {
    return Column(
      children: [
        _buildMachineSelector(activeMachines),
        const SizedBox(height: 12),
        _buildBatchSelector(),
      ],
    );
  }

  Widget _buildMachineSelector(List<MachineModel> machines) {
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

  Widget _buildStatisticsCards(String machineId) {
    final temperatureAsync = ref.watch(temperatureDataProvider(machineId));
    final moistureAsync = ref.watch(moistureDataProvider(machineId));
    final oxygenAsync = ref.watch(oxygenDataProvider(machineId));

    return Column(
      children: [
        // Temperature Card
        temperatureAsync.when(
          data: (readings) => TemperatureStatisticCard(
            currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
            hourlyReadings: readings.map((r) => r.value).toList(),
            lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          ),
          loading: () => _buildLoadingCard(),
          error: (error, stack) => _buildErrorCard('Temperature'),
        ),
        const SizedBox(height: 16),
        
        // Moisture Card
        moistureAsync.when(
          data: (readings) => MoistureStatisticCard(
            currentMoisture: readings.isNotEmpty ? readings.last.value : 0.0,
            hourlyReadings: readings.map((r) => r.value).toList(),
            lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          ),
          loading: () => _buildLoadingCard(),
          error: (error, stack) => _buildErrorCard('Moisture'),
        ),
        const SizedBox(height: 16),
        
        // Air Quality Card
        oxygenAsync.when(
          data: (readings) => OxygenStatisticCard(
            currentOxygen: readings.isNotEmpty ? readings.last.value : 0.0,
            hourlyReadings: readings.map((r) => r.value).toList(),
            lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          ),
          loading: () => _buildLoadingCard(),
          error: (error, stack) => _buildErrorCard('Air Quality'),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorCard(String title) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 36, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Error loading $title data',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh(WidgetRef ref, String machineId) async {
    ref.invalidate(temperatureDataProvider(machineId));
    ref.invalidate(moistureDataProvider(machineId));
    ref.invalidate(oxygenDataProvider(machineId));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}