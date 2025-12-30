import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'temperature_stats_view.dart';
import 'moisture_stats_view.dart';
import 'oxygen_stats_view.dart';
import '../../data/providers/machine_providers.dart';
import '../../data/providers/selected_machine_provider.dart'; 
import '../../data/models/machine_model.dart';
import '../../services/sess_service.dart';

class StatisticsScreen extends ConsumerWidget {
  final String? focusedMachineId;

  const StatisticsScreen({super.key, this.focusedMachineId});

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
              backgroundColor: Colors.teal,
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.teal,
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
                // Use focusedMachineId or first machine
                final initialId = focusedMachineId ?? activeMachines.first.id!;
                Future.microtask(() {
                  ref.read(selectedMachineIdProvider.notifier).setMachine(initialId);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () => _handleRefresh(ref, teamId),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _MachineSelector(machines: activeMachines),
                    const SizedBox(height: 12),
                    _MachineStatsView(machines: activeMachines),
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

  Future<void> _handleRefresh(WidgetRef ref, String teamId) async {
    ref.invalidate(machinesStreamProvider(teamId));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Separate widget for machine selector - only rebuilds when selection changes
class _MachineSelector extends ConsumerWidget {
  final List<MachineModel> machines;

  const _MachineSelector({required this.machines});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.precision_manufacturing, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMachineId,
                isExpanded: true,
                items: machines.map((machine) => DropdownMenuItem(
                  value: machine.id!,
                  child: Text(machine.machineName),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(selectedMachineIdProvider.notifier).setMachine(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for machine stats - only rebuilds when selected machine changes
class _MachineStatsView extends ConsumerWidget {
  final List<MachineModel> machines;

  const _MachineStatsView({required this.machines});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    
    final selectedMachine = machines.firstWhere(
      (m) => m.id == selectedMachineId,
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: selectedMachine.isArchived ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedMachine.isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selectedMachine.isArchived ? Colors.grey.shade100 : Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 16,
                  color: selectedMachine.isArchived ? Colors.grey.shade600 : Colors.teal.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedMachine.machineName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: selectedMachine.isArchived ? Colors.grey.shade700 : Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        'ID: ${selectedMachine.id}',
                        style: TextStyle(
                          fontSize: 10,
                          color: selectedMachine.isArchived ? Colors.grey.shade600 : Colors.teal.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TemperatureStatsView(machineId: selectedMachine.id!),
                const SizedBox(height: 8),
                OxygenStatsView(machineId: selectedMachine.id!),
                const SizedBox(height: 8),
                MoistureStatsView(machineId: selectedMachine.id!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}