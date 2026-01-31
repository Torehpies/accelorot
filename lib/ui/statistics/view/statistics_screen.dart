import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/temperature_statistic_card.dart';
import '../widgets/moisture_statistic_card.dart';
import '../widgets/oxygen_statistic_card.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/selected_machine_provider.dart';
import '../../../data/providers/statistics_providers.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';
import '../../activity_logs/widgets/mobile/batch_selector.dart';
import '../../activity_logs/widgets/mobile/machine_selector.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  final String? focusedMachineId;

  const StatisticsScreen({super.key, this.focusedMachineId});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String? selectedBatch;
  String? _previousMachineId;

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
            appBar: kIsWeb ? null : MobileHeader(title: 'Statistics'),

            body: const Center(
              child: Text(
                'No team assigned. Please contact your administrator.',
              ),
            ),
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: kIsWeb ? null : MobileHeader(title: 'Statistics'),
          body: machinesAsync.when(
            data: (machines) {
              // For statistics: show both active and archived machines
              // Active machines first, then archived at the bottom
              final activeMachines = machines
                  .where((m) => !m.isArchived && m.id != null)
                  .toList();
              final archivedMachines = machines
                  .where((m) => m.isArchived && m.id != null)
                  .toList();
              final allMachines = [...activeMachines, ...archivedMachines];

              if (allMachines.isEmpty) {
                return const Center(child: Text('No machines available'));
              }

              // Initialize selected machine if needed
              final selectedMachineId = ref.watch(selectedMachineIdProvider);
              if (selectedMachineId.isEmpty ||
                  !activeMachines.any((m) => m.id == selectedMachineId)) {
                // Use focusedMachineId or first machine
                final initialId =
                    widget.focusedMachineId ?? activeMachines.first.id!;
                Future.microtask(() {
                  ref
                      .read(selectedMachineIdProvider.notifier)
                      .setMachine(initialId);
                });
                return const Center(child: CircularProgressIndicator());
              }

              // Auto-select current batch when machine changes
              final selectedMachine = allMachines.firstWhere(
                (m) => m.id == selectedMachineId,
              );
              if (_previousMachineId != selectedMachineId) {
                Future.microtask(() {
                  setState(() {
                    _previousMachineId = selectedMachineId;
                    selectedBatch = selectedMachine.currentBatchId;
                  });
                });
              }

              return RefreshIndicator(
                onRefresh: () => _handleRefresh(ref, selectedBatch ?? ''),
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
                    onPressed: () =>
                        ref.invalidate(machinesStreamProvider(teamId)),
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
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return Column(
      children: [
        MachineSelector(
          selectedMachineId: selectedMachineId,
          onChanged: (machineId) {
            if (machineId != null) {
              ref
                  .read(selectedMachineIdProvider.notifier)
                  .setMachine(machineId);
            }
          },
          isCompact: false,
        ),
        const SizedBox(height: 12),
        _buildBatchSelector(),
      ],
    );
  }

  Widget _buildBatchSelector() {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return BatchSelector(
      selectedBatchId: selectedBatch,
      selectedMachineId: selectedMachineId,
      onChanged: (batchId) {
        setState(() {
          selectedBatch = batchId;
        });
      },
      showLabel: false,
      showAllOption: false, // No "All Batches" option in statistics
      showOnlyActive: false, // Show both active and completed batches
      isCompact: false,
    );
  }

  Widget _buildStatisticsCards(String machineId) {
    // Watch data for selected batch
    final batchId = selectedBatch ?? '';
    final temperatureAsync = ref.watch(temperatureDataProvider(batchId));
    final moistureAsync = ref.watch(moistureDataProvider(batchId));
    final oxygenAsync = ref.watch(oxygenDataProvider(batchId));

    return Column(
      children: [
        // Temperature Card
        temperatureAsync.when(
          data: (readings) => TemperatureStatisticCard(
            currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
            readings: readings,
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
            readings: readings,
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
            readings: readings,
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
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

  Future<void> _handleRefresh(WidgetRef ref, String batchId) async {
    ref.invalidate(temperatureDataProvider(batchId));
    ref.invalidate(moistureDataProvider(batchId));
    ref.invalidate(oxygenDataProvider(batchId));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
