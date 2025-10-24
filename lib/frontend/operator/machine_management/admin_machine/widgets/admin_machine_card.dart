import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_machine_controller.dart';
import '../../widgets/machine_detail_row.dart';
import '../../widgets/confirmation_dialog.dart';
import 'edit_machine_modal.dart';

class AdminMachineCard extends StatelessWidget {
  final dynamic machine;
  final AdminMachineController controller;

  const AdminMachineCard({
    super.key,
    required this.machine,
    required this.controller,
  });

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditMachineModal(
        controller: controller,
        machine: machine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = controller.isExpanded(machine.machineId);
    final userName = controller.getUserName(machine.userId) ?? 'Unknown User';
    final dateStr = DateFormat('MMM-dd-yyyy').format(machine.dateCreated);

    return Column(
      children: [
        // Collapsed header
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.devices, color: Colors.teal.shade700, size: 20),
            ),
            title: Text(
              machine.machineName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'ID: ${machine.machineId}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.chevron_right,
              color: Colors.teal.shade600,
              size: 24,
            ),
            onTap: () => controller.toggleExpanded(machine.machineId),
          ),
        ),

        // Expanded card details
        if (isExpanded)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Title and Action Buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices,
                        color: Colors.teal.shade700,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        machine.machineName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons - Right Side (Compact)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button (only for active machines)
                        if (!controller.showArchived)
                          InkWell(
                            onTap: () => _showEditModal(context),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.blue.shade700,
                                size: 16,
                              ),
                            ),
                          ),
                        if (!controller.showArchived) const SizedBox(width: 6),
                        
                        // Archive/Restore button
                        InkWell(
                          onTap: () async {
                            if (controller.showArchived) {
                              // Restore action
                              final confirmed = await showConfirmationDialog(
                                context,
                                'Restore Machine',
                                'Are you sure you want to restore "${machine.machineName}"?',
                              );
                              if (confirmed == true) {
                                await controller.restoreMachine(machine.machineId);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${machine.machineName} restored successfully'),
                                    backgroundColor: Colors.teal,
                                  ),
                                );
                              }
                            } else {
                              // Archive action
                              final confirmed = await showConfirmationDialog(
                                context,
                                'Archive Machine',
                                'Are you sure you want to archive "${machine.machineName}"?',
                              );
                              if (confirmed == true) {
                                try {
                                  await controller.archiveMachine(machine.machineId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${machine.machineName} moved to archive'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  final errorMsg = e.toString().contains('logged in')
                                      ? '⚠️ You must be logged in to archive machines'
                                      : 'Failed to archive: $e';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMsg),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: controller.showArchived
                                  ? Colors.teal.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: controller.showArchived
                                    ? Colors.teal.shade200
                                    : Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              controller.showArchived
                                  ? Icons.restore
                                  : Icons.delete_outline,
                              color: controller.showArchived
                                  ? Colors.teal.shade700
                                  : Colors.red.shade700,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
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
                  label: 'Assigned User:',
                  value: userName,
                ),
                const SizedBox(height: 8),
                MachineDetailRow(
                  label: 'Date Created:',
                  value: dateStr,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}