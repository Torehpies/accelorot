// lib/ui/machine_management/widgets/admin/web_machine_details_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/machine_model.dart';
import '../admin/web_machine_info_row.dart';

class WebMachineDetailsView extends StatelessWidget {
  final MachineModel machine;
  final String teamId;
  final VoidCallback onArchive;

  const WebMachineDetailsView({
    super.key,
    required this.machine,
    required this.teamId,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing,
                    color: Color(0xFF065F46),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machine.machineName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Machine Details',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MachineInfoRow(
                    icon: Icons.tag,
                    label: 'ID',
                    value: machine.machineId,
                  ),
                  const SizedBox(height: 12),
                  MachineInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Created',
                    value: dateFormat.format(machine.dateCreated),
                  ),
                  if (machine.currentBatchId != null) ...[
                    const SizedBox(height: 12),
                    MachineInfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Current Batch',
                      value: machine.currentBatchId!,
                    ),
                  ],
                  if (machine.lastModified != null) ...[
                    const SizedBox(height: 12),
                    MachineInfoRow(
                      icon: Icons.update,
                      label: 'Modified',
                      value: dateFormat.format(machine.lastModified!),
                    ),
                  ],
                  const SizedBox(height: 12),
                  MachineInfoRow(
                    icon: machine.isArchived
                        ? Icons.archive
                        : Icons.check_circle,
                    label: 'Status',
                    value: machine.isArchived ? 'Archived' : 'Active',
                  ),
                ],
              ),
            ),
          ),

          // Footer
          if (!machine.isArchived)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onArchive,
                    icon: const Icon(Icons.archive, size: 18),
                    label: const Text('Archive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
