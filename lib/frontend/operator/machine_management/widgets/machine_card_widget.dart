// lib/frontend/operator/machine_management/widgets/machine_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/machine_controller.dart';
import 'machine_detail_row.dart';
import 'confirmation_dialog.dart';

class MachineCardWidget extends StatelessWidget {
  final dynamic machine;
  final MachineController controller;

  const MachineCardWidget({
    super.key,
    required this.machine,
    required this.controller,
  });

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
          Stack(
            children: [
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
                    Row(
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    MachineDetailRow(
                      label: 'Machine ID:',
                      value: machine.machineId,
                    ),
                    const SizedBox(height: 8),
                    MachineDetailRow(
                      label: 'User:',
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

              // Archive/Restore button (top-right)
              Positioned(
                top: 0,
                right: 0,
                child: controller.showArchived
                    ? IconButton(
                        icon: Icon(Icons.restore,
                            color: Colors.teal.shade800, size: 22),
                        tooltip: 'Restore Machine',
                        onPressed: () async {
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
                              ),
                            );
                          }
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade600, size: 20),
                        tooltip: 'Archive Machine',
                        onPressed: () async {
                          final confirmed = await showConfirmationDialog(
                            context,
                            'Archive Machine',
                            'Are you sure you want to archive "${machine.machineName}"?',
                          );
                          if (confirmed == true) {
                            await controller.deleteMachine(machine.machineId);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${machine.machineName} moved to archive'),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}