// lib/ui/activity_logs/widgets/web/web_machine_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/machine_providers.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../services/sess_service.dart';
import 'web_dropdown.dart';
import 'web_table_container.dart';

class WebMachineSelector extends ConsumerWidget {
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final DropdownDisplayMode displayMode;
  final bool isLoading;

  const WebMachineSelector({
    super.key,
    required this.selectedMachineId,
    required this.onChanged,
    required this.displayMode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionService = SessionService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        final shouldShowLoading =
            userSnapshot.connectionState == ConnectionState.waiting ||
            isLoading;

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return WebDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            isLoading: true,
            displayMode: displayMode,
          );
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) {
          return WebDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            disabledHint: 'No Team Found',
            displayMode: displayMode,
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return machinesAsync.when(
          data: (machines) {
            final activeMachines = machines
                .where((m) => !m.isArchived)
                .toList();

            if (activeMachines.isEmpty) {
              return WebDropdown<String>(
                value: null,
                label: 'Machine',
                hintText: 'All Machines',
                items: const [],
                onChanged: (_) {},
                icon: Icons.precision_manufacturing,
                disabledHint: 'No Machines',
                displayMode: displayMode,
                isLoading: shouldShowLoading,
              );
            }

            final selectedMachine =
                activeMachines.any((m) => m.id == selectedMachineId)
                ? activeMachines.firstWhere((m) => m.id == selectedMachineId)
                : null;

            return _WebMachineDropdownInner(
              selectedMachineId: selectedMachineId,
              selectedMachineName:
                  selectedMachine?.machineName ?? 'All Machines',
              activeMachines: activeMachines,
              onChanged: onChanged,
              displayMode: displayMode,
              isLoading: shouldShowLoading,
            );
          },
          loading: () => WebDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            isLoading: true,
            displayMode: displayMode,
          ),
          error: (_, _) => WebDropdown<String>(
            value: null,
            label: 'Machine',
            hintText: 'All Machines',
            items: const [],
            onChanged: (_) {},
            icon: Icons.precision_manufacturing,
            disabledHint: 'Error loading',
            displayMode: displayMode,
          ),
        );
      },
    );
  }
}

class _WebMachineDropdownInner extends StatelessWidget {
  final String? selectedMachineId;
  final String selectedMachineName;
  final List<MachineModel> activeMachines;
  final ValueChanged<String?> onChanged;
  final DropdownDisplayMode displayMode;
  final bool isLoading;

  const _WebMachineDropdownInner({
    required this.selectedMachineId,
    required this.selectedMachineName,
    required this.activeMachines,
    required this.onChanged,
    required this.displayMode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return WebDropdown<String>(
      value: selectedMachineId,
      label: 'Machine',
      hintText: 'All Machines',
      displayText: selectedMachineId == null
          ? 'All Machines'
          : selectedMachineName,
      icon: Icons.precision_manufacturing,
      onChanged: onChanged,
      displayMode: displayMode,
      isLoading: isLoading,
      items: [
        const PopupMenuItem<String>(value: null, child: Text('All Machines')),
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
