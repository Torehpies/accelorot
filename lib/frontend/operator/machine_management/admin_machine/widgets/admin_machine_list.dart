// lib/frontend/operator/machine_management/admin_machine/widgets/admin_machine_list.dart

import 'package:flutter/material.dart';
import '../controllers/admin_machine_controller.dart';
import 'admin_machine_card.dart';

class AdminMachineList extends StatelessWidget {
  final AdminMachineController controller;

  const AdminMachineList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final machines = controller.filteredMachines;

    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.showArchived ? Icons.archive : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'No machines found'
                  : controller.showArchived
                      ? 'No archived machines'
                      : 'No machines available. Add one to get started!',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        return AdminMachineCard(
          machine: machine,
          controller: controller,
        );
      },
    );
  }
}