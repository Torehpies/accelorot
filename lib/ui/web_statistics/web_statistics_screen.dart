import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/statistics_providers.dart';
import '../mobile_statistics/widgets/temperature_statistic_card.dart';
import '../mobile_statistics/widgets/moisture_statistic_card.dart';
import '../mobile_statistics/widgets/oxygen_statistic_card.dart';
import '../../data/providers/machine_providers.dart';
import '../../data/providers/selected_machine_provider.dart'; 
import '../../data/models/machine_model.dart';
import '../../services/sess_service.dart';

class WebStatisticsScreen extends ConsumerWidget {
  final String? focusedMachineId;

  const WebStatisticsScreen({super.key, this.focusedMachineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            appBar: AppBar(
              title: const Text('Statistics'),
              backgroundColor: Colors.teal.shade700,
            ),
            body: const Center(
              child: Text('No team assigned. Please contact your administrator.'),
            ),
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              "Statistics",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.teal.shade700,
            elevation: 0,
          ),
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
                final initialId = focusedMachineId ?? activeMachines.first.id!;
                Future.microtask(() {
                  ref.read(selectedMachineIdProvider.notifier).setMachine(initialId);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () => _handleRefresh(ref, selectedMachineId),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final padding = width < 600 ? 16.0 : 24.0;
                    
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(width, activeMachines, ref),
                          const SizedBox(height: 24),
                          _buildStatisticsCards(width, selectedMachineId, ref),
                        ],
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

  Widget _buildHeader(double width, List<MachineModel> machines, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: width < 600
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(),
                const SizedBox(height: 16),
                _buildMachineSelector(machines, ref),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildHeaderContent()),
                const SizedBox(width: 16),
                _buildMachineSelector(machines, ref),
              ],
            ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.precision_manufacturing,
            color: Colors.teal.shade700,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Machine Monitoring',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time sensor data and analytics',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMachineSelector(List<MachineModel> machines, WidgetRef ref) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics, color: Colors.grey[700], size: 18),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMachineId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(double width, String machineId, WidgetRef ref) {
    // Determine layout based on width
    if (width < 700) {
      // Mobile: Single column
      return Column(
        children: [
          _buildTemperatureCard(machineId, ref),
          const SizedBox(height: 20),
          _buildMoistureCard(machineId, ref),
          const SizedBox(height: 20),
          _buildOxygenCard(machineId, ref),
        ],
      );
    } else if (width < 1100) {
      // Tablet: 2 columns
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTemperatureCard(machineId, ref)),
              const SizedBox(width: 20),
              Expanded(child: _buildMoistureCard(machineId, ref)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOxygenCard(machineId, ref)),
              const Expanded(child: SizedBox()), // Empty space
            ],
          ),
        ],
      );
    } else {
      // Desktop: 3 columns
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTemperatureCard(machineId, ref)),
          const SizedBox(width: 20),
          Expanded(child: _buildMoistureCard(machineId, ref)),
          const SizedBox(width: 20),
          Expanded(child: _buildOxygenCard(machineId, ref)),
        ],
      );
    }
  }

  Widget _buildTemperatureCard(String machineId, WidgetRef ref) {
    final temperatureAsync = ref.watch(temperatureDataProvider(machineId));

    return _buildSensorCard(
      title: 'Temperature',
      icon: Icons.thermostat,
      iconColor: Colors.orange,
      asyncValue: temperatureAsync,
      builder: (readings) => TemperatureStatisticCard(
        currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(temperatureDataProvider(machineId)),
    );
  }

  Widget _buildMoistureCard(String machineId, WidgetRef ref) {
    final moistureAsync = ref.watch(moistureDataProvider(machineId));

    return _buildSensorCard(
      title: 'Moisture',
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      asyncValue: moistureAsync,
      builder: (readings) => MoistureStatisticCard(
        currentMoisture: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(moistureDataProvider(machineId)),
    );
  }

  Widget _buildOxygenCard(String machineId, WidgetRef ref) {
    final oxygenAsync = ref.watch(oxygenDataProvider(machineId));

    return _buildSensorCard(
      title: 'Air Quality',
      icon: Icons.air,
      iconColor: Colors.green,
      asyncValue: oxygenAsync,
      builder: (readings) => OxygenStatisticCard(
        currentOxygen: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(oxygenDataProvider(machineId)),
    );
  }

  Widget _buildSensorCard<T>({
    required String title,
    required IconData icon,
    required Color iconColor,
    required AsyncValue<List<T>> asyncValue,
    required Widget Function(List<T>) builder,
    required VoidCallback onRetry,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: asyncValue.when(
              data: (readings) => builder(readings),
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stack) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 36, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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