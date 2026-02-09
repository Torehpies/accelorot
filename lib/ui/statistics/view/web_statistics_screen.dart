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
import '../../core/widgets/stats_skeleton.dart';

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return RefreshIndicator(
                      onRefresh: () => _handleRefresh(ref, selectedBatch ?? ''),
                      child: SingleChildScrollView(
                        // Use physics that allows scroll only when content exceeds viewport
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          // Ensure minimum height equals viewport height
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: _getVerticalPadding(constraints.maxWidth),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(allMachines, ref, constraints.maxWidth),
                                  const SizedBox(height: 24),
                                  _buildStatisticsCards(constraints.maxWidth),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildHeader(List<MachineModel> machines, WidgetRef ref, double width) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    // Responsive header layout
    if (width < 700) {
      // Mobile: Stack vertically
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
    } else {
      // Desktop: Side by side
      return Row(
        children: [
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
          const SizedBox(width: 12),
          Expanded(child: _buildBatchSelector()),
        ],
      );
    }
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

  Widget _buildStatisticsCards(double width) {
    // Watch the actual data providers with the selected batch
    final batchId = selectedBatch ?? '';
    final temperatureAsync = ref.watch(temperatureDataProvider(batchId));
    final moistureAsync = ref.watch(moistureDataProvider(batchId));
    final oxygenAsync = ref.watch(oxygenDataProvider(batchId));

    // Determine chart height based on screen width
    final chartHeight = _getChartHeight(width);
    final cardSpacing = _getCardSpacing(width);

    // Build cards with actual backend data
    final cards = [
      temperatureAsync.when(
        data: (readings) => TemperatureStatisticCard(
          currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
          readings: readings,
          lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          chartHeight: chartHeight,
        ),
        loading: () => const StatisticCardSkeleton(
          accentColor: Colors.orange,
          title: 'Temperature',
          subtitle: '',
        ),
        error: (error, stack) => _buildErrorCard('Temperature', error),
      ),
      moistureAsync.when(
        data: (readings) => MoistureStatisticCard(
          currentMoisture: readings.isNotEmpty ? readings.last.value : 0.0,
          readings: readings,
          lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          chartHeight: chartHeight,
        ),
        loading: () => const StatisticCardSkeleton(
          accentColor: Colors.blue,
          title: 'Moisture',
          subtitle: '',
        ),
        error: (error, stack) => _buildErrorCard('Moisture', error),
      ),
      oxygenAsync.when(
        data: (readings) => OxygenStatisticCard(
          currentOxygen: readings.isNotEmpty ? readings.last.value : 0.0,
          readings: readings,
          lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
          chartHeight: chartHeight,
        ),
        loading: () => const StatisticCardSkeleton(
          accentColor: Colors.purple,
          title: 'Air Quality',
          subtitle: '',
        ),
        error: (error, stack) => _buildErrorCard('Air Quality', error),
      ),
    ];

    // Responsive layout with different breakpoints
    if (width < 700) {
      // Mobile: Single column
      return Column(
        children: cards
            .map(
              (card) => Padding(
                padding: EdgeInsets.only(bottom: cardSpacing),
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
                SizedBox(width: cardSpacing),
                Expanded(child: cards[1]),
              ],
            ),
          ),
          SizedBox(height: cardSpacing),
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
    } else if (width < 1600) {
      // Medium Desktop: 3 columns with moderate spacing
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: cardSpacing),
            Expanded(child: cards[1]),
            SizedBox(width: cardSpacing),
            Expanded(child: cards[2]),
          ],
        ),
      );
    } else {
      // Large Desktop: 3 columns with more spacing and max width constraint
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1800),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[0]),
                SizedBox(width: cardSpacing),
                Expanded(child: cards[1]),
                SizedBox(width: cardSpacing),
                Expanded(child: cards[2]),
              ],
            ),
          ),
        ),
      );
    }
  }

  // Get responsive vertical padding (combined top and bottom)
  double _getVerticalPadding(double width) {
    if (width < 700) {
      return 16; // Mobile
    } else if (width < 1100) {
      return 20; // Tablet
    } else if (width < 1600) {
      return 6; // Medium Desktop
    } else {
      return 32; // Large Desktop
    }
  }

  // Get responsive chart height
  double _getChartHeight(double width) {
    if (width < 700) {
      return 250; // Mobile
    } else if (width < 1100) {
      return 280; // Tablet
    } else if (width < 1600) {
      return 300; // Medium Desktop
    } else {
      return 350; // Large Desktop
    }
  }

  // Get responsive card spacing
  double _getCardSpacing(double width) {
    if (width < 700) {
      return 16;
    } else if (width < 1100) {
      return 20;
    } else if (width < 1600) {
      return 24;
    } else {
      return 32;
    }
  }

  Future<void> _handleRefresh(WidgetRef ref, String batchId) async {
    ref.invalidate(temperatureDataProvider(batchId));
    ref.invalidate(moistureDataProvider(batchId));
    ref.invalidate(oxygenDataProvider(batchId));
    await Future.delayed(const Duration(milliseconds: 500));
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