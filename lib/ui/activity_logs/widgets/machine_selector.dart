// lib/ui/activity_logs/widgets/machine_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/team_providers.dart';

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
        if (teamId == null) return const SizedBox.shrink();

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));
        

        final machines = machinesAsync.value ?? [];
        final isLoading = machinesAsync.isLoading && !machinesAsync.hasValue;
        
        if (isLoading) {
          return const SizedBox.shrink();
        }
        
        if (machines.isEmpty && !machinesAsync.isLoading) return const SizedBox.shrink();

        final activeMachines = machines
            .where((m) => !m.isArchived)
            .toList();
        final archivedMachines = machines
            .where((m) => m.isArchived)
            .toList();

        activeMachines.sort((a, b) {
          if (a.lastModified == null && b.lastModified == null) {
            return a.machineName.compareTo(b.machineName);
          }
          if (a.lastModified == null) {
            return 1; // a after b
          }
          if (b.lastModified == null) {
            return -1; // a before b
          }
          final compare = b.lastModified!.compareTo(
            a.lastModified!,
          ); // descending
          return compare != 0
              ? compare
              : a.machineName.compareTo(b.machineName);
        });

        archivedMachines.sort((a, b) {
          if (a.lastModified == null && b.lastModified == null) {
            return a.machineName.compareTo(b.machineName);
          }
          if (a.lastModified == null) {
            return 1; 
          }
          if (b.lastModified == null) {
            return -1; 
          }
          final compare = b.lastModified!.compareTo(
            a.lastModified!,
          ); // descending
          return compare != 0
              ? compare
              : a.machineName.compareTo(b.machineName);
        });

            // Combine: active first, then archived
        final sortedMachines = [...activeMachines, ...archivedMachines];
        
        // Ensure selectedMachineId is valid
        final selectedMachine = sortedMachines.any((m) => m.id == selectedMachineId) 
            ? selectedMachineId 
            : null;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: isCompact ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: isCompact ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: isCompact
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.precision_manufacturing,
                color: isCompact ? Colors.teal.shade700 : Colors.grey[700],
                size: isCompact ? 18 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedMachine,
                  hint: Text(
                    'Select Machine',
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isCompact ? Colors.teal.shade700 : Colors.teal,
                  ),
                  menuMaxHeight: 400,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Select Machine'),
                    ),
                    ...sortedMachines.map((machine) {
                      return DropdownMenuItem<String>(
                        value: machine.id,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                machine.machineName,
                                style: TextStyle(fontSize: isCompact ? 13 : 14),
                              ),
                            ),
                            if (machine.isArchived)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Archived',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
