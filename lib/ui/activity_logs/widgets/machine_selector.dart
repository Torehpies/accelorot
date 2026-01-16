// lib/ui/activity_logs/widgets/machine_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../services/sess_service.dart';

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
    final sessionService = SessionService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) return const SizedBox.shrink();

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return machinesAsync.when(
          data: (machines) {
            if (machines.isEmpty) return const SizedBox.shrink();

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

            // Sort archived machines: by lastModified descending (nulls last), then by machineName
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
                      value: selectedMachineId,
                      hint: Text(
                        'All Machines',
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
                          child: Text('All Machines'),
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
      },
    );
  }
}
