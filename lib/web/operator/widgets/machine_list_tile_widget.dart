// lib/frontend/operator/machine_management/widgets/machine_list_tile_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/models/machine_model.dart'
    show MachineModel;

class MachineListTileWidget extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;

  const MachineListTileWidget({
    super.key,
    required this.machine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = !machine.isArchived;
    final machineId = machine.machineId;
    final machineName = machine.machineName;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? Colors.teal.shade100 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? Colors.teal.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.precision_manufacturing,
            color: isActive ? Colors.teal.shade700 : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          machineName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'ID: $machineId',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Active' : 'Disabled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.teal),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
