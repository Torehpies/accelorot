import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/machine_model.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';
import '../../../core/ui/confirmation_dialog.dart';
import 'web_machine_view_dialog.dart';
import 'web_edit_machine_modal.dart';

class WebAdminMachineCard extends ConsumerWidget {
  final MachineModel machine;
  final String teamId;

  const WebAdminMachineCard({
    super.key,
    required this.machine,
    required this.teamId,
  });

  void _showMachineViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WebMachineViewDialog(
        machine: machine,
        teamId: teamId,
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: WebEditMachineModal(
            machine: machine,
            teamId: teamId,
          ),
        ),
      ),
    );
  }

  Future<void> _handleArchive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      'Archive Machine',
      'Are you sure you want to archive "${machine.machineName}"?',
    );

    if (confirmed == true) {
      await ref.read(adminMachineProvider.notifier).archiveMachine(
            machine.id!,
            teamId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine archived successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      'Restore Machine',
      'Are you sure you want to restore "${machine.machineName}"?',
    );

    if (confirmed == true) {
      await ref.read(adminMachineProvider.notifier).restoreMachine(
            machine.id!,
            teamId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM dd, yyyy').format(machine.dateCreated);
    final isArchived = machine.isArchived;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMachineViewDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isArchived ? Colors.grey[100] : Colors.teal[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.precision_manufacturing,
                  size: 28,
                  color: isArchived ? Colors.grey : Colors.teal,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${machine.machineId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        if (isArchived)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ARCHIVED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isArchived) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context, ref),
                      tooltip: 'Edit',
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.archive, size: 20),
                      onPressed: () => _handleArchive(context, ref),
                      tooltip: 'Archive',
                      color: Colors.orange,
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(Icons.restore, size: 20),
                      onPressed: () => _handleRestore(context, ref),
                      tooltip: 'Restore',
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}