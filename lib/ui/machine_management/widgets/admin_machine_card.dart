import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../view_model/admin_machine_notifier.dart';
import '../../../frontend/operator/machine_management/widgets/machine_detail_row.dart';
import '../../../frontend/operator/machine_management/widgets/confirmation_dialog.dart';
import '../../../frontend/operator/main_navigation.dart';
import 'edit_machine_modal.dart';

class AdminMachineCard extends ConsumerWidget {
  final MachineModel machine;
  final String teamId;

  const AdminMachineCard({
    super.key,
    required this.machine,
    required this.teamId,
  });

  void _showViewDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AdminMachineViewDialog(
        machine: machine,
        teamId: teamId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM-dd-yyyy').format(machine.dateCreated);
    final isArchived = machine.isArchived;

    return InkWell(
      onTap: () => _showViewDialog(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: isArchived ? Colors.grey[100] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isArchived ? Colors.grey[300]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
        child: Opacity(
          opacity: isArchived ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isArchived
                            ? Colors.grey.shade300
                            : Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices,
                        color: isArchived
                            ? Colors.grey.shade600
                            : Colors.teal.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machine.machineName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isArchived
                                  ? Colors.grey[700]
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Badge
                    if (isArchived)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.block,
                              size: 14,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Disabled',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Machine Details
                MachineDetailRow(
                  label: 'Machine ID:',
                  value: machine.machineId,
                ),
                const SizedBox(height: 8),
                MachineDetailRow(
                  label: 'Assigned Users:',
                  value: 'All Team Members',
                ),
                const SizedBox(height: 8),
                MachineDetailRow(label: 'Date Created:', value: dateStr),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// View Dialog (same as old admin_machine_view_dialog.dart)
class _AdminMachineViewDialog extends ConsumerWidget {
  final MachineModel machine;
  final String teamId;

  const _AdminMachineViewDialog({
    required this.machine,
    required this.teamId,
  });

  Future<void> _handleArchive(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context); // Close dialog

    final confirmed = await showConfirmationDialog(
      context,
      'Archive Machine',
      'Are you sure you want to archive "${machine.machineName}"? This will disable the machine.',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(adminMachineProvider.notifier).archiveMachine(
              teamId,
              machine.machineId,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${machine.machineName} moved to archive'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to archive: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);

    final confirmed = await showConfirmationDialog(
      context,
      'Restore Machine',
      'Are you sure you want to restore "${machine.machineName}"? This will reactivate the machine.',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(adminMachineProvider.notifier).restoreMachine(
              teamId,
              machine.machineId,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${machine.machineName} restored successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to restore: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditMachineModal(
        machine: machine,
        teamId: teamId,
      ),
    );
  }

  void _handleViewDetails(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(focusedMachine: machine),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchived = machine.isArchived;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isArchived ? Colors.grey.shade200 : Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.precision_manufacturing,
                color: isArchived ? Colors.grey.shade500 : Colors.teal.shade700,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isArchived ? 'Archived Machine' : 'Manage Machine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Machine Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          machine.machineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${machine.machineId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              isArchived
                  ? 'This machine is currently disabled. Restore it to reactivate and make it available again.'
                  : 'Edit details, archive, or view complete information for this machine.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            if (!isArchived) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleEdit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleViewDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleArchive(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Archive',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleRestore(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Restore',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}