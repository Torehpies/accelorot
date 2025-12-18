// lib/ui/activity_logs/widgets/unified/unified_machine_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/machine_providers.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../services/sess_service.dart';
import 'unified_dropdown.dart';

class UnifiedMachineSelector extends ConsumerWidget {
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;

  const UnifiedMachineSelector({
    super.key,
    required this.selectedMachineId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionService = SessionService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return UnifiedDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            isLoading: true,
          );
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) {
          return UnifiedDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            disabledHint: 'No Team Found',
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return machinesAsync.when(
          data: (machines) {
            final activeMachines = machines.where((m) => !m.isArchived).toList();
            
            if (activeMachines.isEmpty) {
              return UnifiedDropdown<String>(
                value: null,
                label: 'Machine',
                hintText: 'All Machines',
                items: const [],
                onChanged: (_) {},
                icon: Icons.precision_manufacturing,
                disabledHint: 'No Machines',
              );
            }

            final selectedMachine = activeMachines.any((m) => m.id == selectedMachineId)
                ? activeMachines.firstWhere((m) => m.id == selectedMachineId)
                : null;

            return _UnifiedMachineDropdownInner(
              selectedMachineId: selectedMachineId,
              selectedMachineName: selectedMachine?.machineName ?? 'All Machines',
              activeMachines: activeMachines,
              onChanged: onChanged,
            );
          },
          loading: () => UnifiedDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            isLoading: true,
          ),
          error: (_, __) => UnifiedDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            disabledHint: 'Error loading',
          ),
        );
      },
    );
  }
}


class _UnifiedMachineDropdownInner extends StatelessWidget {
  final String? selectedMachineId;
  final String selectedMachineName;
  final List<MachineModel> activeMachines;
  final ValueChanged<String?> onChanged;

  const _UnifiedMachineDropdownInner({
    required this.selectedMachineId,
    required this.selectedMachineName,
    required this.activeMachines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedDropdown<String>(
      value: selectedMachineId,
      label: 'Machine',
      hintText: 'All Machines',
      displayText: selectedMachineId == null ? 'All Machines' : selectedMachineName,
      icon: Icons.precision_manufacturing,
      onChanged: onChanged,
      items: [
        const PopupMenuItem<String>(
          value: null,
          child: Text('All Machines'),
        ),
        ...activeMachines.map((machine) {
          return PopupMenuItem<String>(
            value: machine.id,
            child: Text(machine.machineName),
          );
        }),
      ],
    );
  }
}
