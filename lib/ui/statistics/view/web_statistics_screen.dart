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
import '../../activity_logs/widgets/mobile/batch_selector.dart';
import '../../activity_logs/widgets/mobile/machine_selector.dart';
import '../../core/widgets/web_base_container.dart';

class WebStatisticsScreen extends ConsumerStatefulWidget {
  final String? focusedMachineId;

  const WebStatisticsScreen({super.key, this.focusedMachineId});

  @override
  ConsumerState<WebStatisticsScreen> createState() =>
      _WebStatisticsScreenState();
}

class _WebStatisticsScreenState extends ConsumerState<WebStatisticsScreen> {
  String? selectedBatch;
  String? _previousMachineId;

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return WebScaffoldContainer(
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) {
          return WebScaffoldContainer(
            child: const Center(
              child: Text(
                'No team assigned. Please contact your administrator.',
              ),
            ),
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return WebScaffoldContainer(
          child: machinesAsync.when(
            data: (machines) {
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
                  !allMachines.any((m) => m.id == selectedMachineId)) {
                final initialId =
                    widget.focusedMachineId ?? allMachines.first.id!;
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

              return WebContentContainer(
                child: RefreshIndicator(
                  onRefresh: () => _handleRefresh(ref, selectedBatch ?? ''),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(allMachines, ref),
                        const SizedBox(height: 32),
                        _buildStatisticsCards(),
                      ],
                    ),
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

  Widget _buildHeader(List<MachineModel> machines, WidgetRef ref) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return Row(
      children: [
        // Machine Selector
        Expanded(
          child: MachineSelector(
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
        ),
        const SizedBox(width: 16),

        // Batch Selector
        Expanded(child: _buildBatchSelector()),
      ],
    );
  }

  Widget _buildBatchSelector() {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return BatchSelector(
      selectedBatchId: selectedBatch,
      selectedMachineId: selectedMachineId,
      onChanged: (batchId) => setState(() => selectedBatch = batchId),
      showLabel: false,
      showAllOption: false,
      showOnlyActive: false,
      isCompact: false,
    );
  }

  Widget _buildStatisticsCards() {
    //final selectedMachineId = ref.watch(selectedMachineIdProvider);
    
    // Watch the actual data providers with the selected batch
    final batchId = selectedBatch ?? '';
    final temperatureAsync = ref.watch(temperatureDataProvider(batchId));
    final moistureAsync = ref.watch(moistureDataProvider(batchId));
    final oxygenAsync = ref.watch(oxygenDataProvider(batchId));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Build cards with actual backend data
        final cards = [
          temperatureAsync.when(
            data: (readings) => TemperatureStatisticCard(
              currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
              readings: readings,
              lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
            ),
            loading: () => _buildLoadingCard('Temperature'),
            error: (error, stack) => _buildErrorCard('Temperature', error),
          ),
          moistureAsync.when(
            data: (readings) => MoistureStatisticCard(
              currentMoisture: readings.isNotEmpty ? readings.last.value : 0.0,
              readings: readings,
              lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
            ),
            loading: () => _buildLoadingCard('Moisture'),
            error: (error, stack) => _buildErrorCard('Moisture', error),
          ),
          oxygenAsync.when(
            data: (readings) => OxygenStatisticCard(
              currentOxygen: readings.isNotEmpty ? readings.last.value : 0.0,
              readings: readings,
              lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
            ),
            loading: () => _buildLoadingCard('Air Quality'),
            error: (error, stack) => _buildErrorCard('Air Quality', error),
          ),
        ];

        // Responsive layout
        if (width < 700) {
          // Mobile: Single column
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: card,
                  ),
                )
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

  Future<void> _handleRefresh(WidgetRef ref, String batchId) async {
    ref.invalidate(temperatureDataProvider(batchId));
    ref.invalidate(moistureDataProvider(batchId));
    ref.invalidate(oxygenDataProvider(batchId));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildLoadingCard(String title) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 12),
            Text(
              'Loading $title...',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, Object error) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              'Error loading $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                final batchId = selectedBatch ?? '';
                ref.invalidate(temperatureDataProvider(batchId));
                ref.invalidate(moistureDataProvider(batchId));
                ref.invalidate(oxygenDataProvider(batchId));
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}