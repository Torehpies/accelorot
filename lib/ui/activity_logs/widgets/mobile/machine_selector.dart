// lib/ui/activity_logs/widgets/mobile/machine_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/machine_providers.dart';
import '../../../../data/providers/team_providers.dart';
import '../../../core/widgets/filters/mobile_selector_button.dart';

/// Reusable machine selector dropdown
class MachineSelector extends ConsumerWidget {
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final bool isCompact;

  const MachineSelector({
    super.key,
    required this.selectedMachineId,
    required this.onChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamIdAsync = ref.watch(currentUserTeamIdProvider);

    return teamIdAsync.when(
      data: (teamId) {
        if (teamId == null) {
          return MobileSelectorButton<dynamic>(
            icon: Icons.precision_manufacturing,
            allLabel: 'All Machines',
            selectedItemId: null,
            items: const [],
            itemId: (_) => '',
            displayName: (_) => '',
            onChanged: (_) {},
            emptyMessage: 'No team',
          );
        }

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return machinesAsync.when(
          data: (machines) {
            // Filter active and archived machines
            final activeMachines =
                machines.where((m) => !m.isArchived).toList();
            final archivedMachines =
                machines.where((m) => m.isArchived).toList();

            // Sort active machines
            activeMachines.sort((a, b) {
              if (a.lastModified == null && b.lastModified == null) {
                return a.machineName.compareTo(b.machineName);
              }
              if (a.lastModified == null) return 1;
              if (b.lastModified == null) return -1;
              final compare = b.lastModified!.compareTo(a.lastModified!);
              return compare != 0
                  ? compare
                  : a.machineName.compareTo(b.machineName);
            });

            // Sort archived machines
            archivedMachines.sort((a, b) {
              if (a.lastModified == null && b.lastModified == null) {
                return a.machineName.compareTo(b.machineName);
              }
              if (a.lastModified == null) return 1;
              if (b.lastModified == null) return -1;
              final compare = b.lastModified!.compareTo(a.lastModified!);
              return compare != 0
                  ? compare
                  : a.machineName.compareTo(b.machineName);
            });

            // Combine: active first, then archived
            final sortedMachines = [...activeMachines, ...archivedMachines];

            return MobileSelectorButton(
              icon: Icons.precision_manufacturing,
              allLabel: 'All Machines',
              selectedItemId: selectedMachineId,
              items: sortedMachines,
              itemId: (m) => m.id ?? '',
              displayName: (m) => m.machineName,
              statusBadge: (m) => m.isArchived ? 'Archived' : null,
              onChanged: onChanged,
              emptyMessage: 'No machines',
            );
          },
          loading: () => MobileSelectorButton<dynamic>(
            icon: Icons.precision_manufacturing,
            allLabel: 'All Machines',
            selectedItemId: null,
            items: const [],
            itemId: (_) => '',
            displayName: (_) => '',
            onChanged: (_) {},
            isLoading: true,
          ),
          error: (_, __) => MobileSelectorButton<dynamic>(
            icon: Icons.precision_manufacturing,
            allLabel: 'All Machines',
            selectedItemId: null,
            items: const [],
            itemId: (_) => '',
            displayName: (_) => '',
            onChanged: (_) {},
            emptyMessage: 'Error loading',
          ),
        );
      },
      loading: () => MobileSelectorButton<dynamic>(
        icon: Icons.precision_manufacturing,
        allLabel: 'All Machines',
        selectedItemId: null,
        items: const [],
        itemId: (_) => '',
        displayName: (_) => '',
        onChanged: (_) {},
        isLoading: true,
      ),
      error: (_, __) => MobileSelectorButton<dynamic>(
        icon: Icons.precision_manufacturing,
        allLabel: 'All Machines',
        selectedItemId: null,
        items: const [],
        itemId: (_) => '',
        displayName: (_) => '',
        onChanged: (_) {},
        emptyMessage: 'Error loading',
      ),
    );
  }
}