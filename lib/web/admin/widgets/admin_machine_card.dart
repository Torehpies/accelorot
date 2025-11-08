// lib/frontend/operator/machine_management/admin_machine/widgets/admin_machine_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_machine_controller.dart';
import '../widgets/machine_detail_row.dart';
import 'admin_machine_view_dialog.dart';

class AdminMachineCard extends StatelessWidget {
  final dynamic machine;
  final AdminMachineController controller;

  const AdminMachineCard({
    super.key,
    required this.machine,
    required this.controller,
  });

  void _showMachineViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AdminMachineViewDialog(machine: machine, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM-dd-yyyy').format(machine.dateCreated);
    final isArchived = machine.isArchived;

    return InkWell(
      onTap: () => _showMachineViewDialog(context),
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
                // Header Row with Icon, Machine Name, and Status
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
                    // Status Badge - Upper Right
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
