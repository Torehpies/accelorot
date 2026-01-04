// lib/ui/machine_management/widgets/shared/machine_table_row.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../widgets/admin/web_machine_status_badge.dart';

class MachineTableRow extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const MachineTableRow({
    super.key,
    required this.machine,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Machine ID
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                machine.machineId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),

          // Name
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                machine.machineName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Date Created
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                dateFormat.format(machine.dateCreated),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: MachineStatusBadge(isArchived: machine.isArchived),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: const Color(0xFF6B7280),
                    tooltip: 'Edit Machine',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: const Color(0xFF6B7280),
                    tooltip: 'View Machine',
                    onPressed: onView,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}