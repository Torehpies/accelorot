// lib/frontend/operator/machine_management/admin_machine/widgets/admin_machine_view_dialog.dart

import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../../main_navigation.dart';
import '../controllers/admin_machine_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import 'edit_machine_modal.dart';

class AdminMachineViewDialog extends StatelessWidget {
  final MachineModel machine;
  final AdminMachineController controller;

  const AdminMachineViewDialog({
    super.key,
    required this.machine,
    required this.controller,
  });

  Future<void> _handleArchive(BuildContext context) async {
    Navigator.pop(context); // Close view dialog first
    
    final confirmed = await showConfirmationDialog(
      context,
      'Archive Machine',
      'Are you sure you want to archive "${machine.machineName}"? This will disable the machine.',
    );

    if (confirmed == true) {
      try {
        await controller.archiveMachine(machine.machineId);
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${machine.machineName} moved to archive'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Delay before refresh
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!context.mounted) return;
        await controller.refresh();
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

  Future<void> _handleRestore(BuildContext context) async {
    Navigator.pop(context); // Close view dialog first
    
    final confirmed = await showConfirmationDialog(
      context,
      'Restore Machine',
      'Are you sure you want to restore "${machine.machineName}"? This will reactivate the machine.',
    );

    if (confirmed == true) {
      try {
        await controller.restoreMachine(machine.machineId);
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${machine.machineName} restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Delay before refresh
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!context.mounted) return;
        await controller.refresh();
      } catch (e) {
        if (!context.mounted) return;
        final errorMsg = e.toString().contains('logged in')
            ? '⚠️ You must be logged in to restore machines'
            : 'Failed to restore: $e';
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

  void _handleEdit(BuildContext context) {
    Navigator.pop(context); // Close view dialog first
    
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

  void _handleViewDetails(BuildContext context) {
    Navigator.pop(context); // Close dialog first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(
          focusedMachine: machine, // ⭐ Switch to operator navigation with focused machine
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArchived = machine.isArchived;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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

            // Machine Info Box
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
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

            // Buttons - Different layouts for active vs archived
            if (!isArchived) ...[
              // Active Machine Buttons (2x2 grid)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleEdit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
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
                      onPressed: () => _handleArchive(context),
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
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Archived Machine Buttons (1 row)
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
                      onPressed: () => _handleRestore(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
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