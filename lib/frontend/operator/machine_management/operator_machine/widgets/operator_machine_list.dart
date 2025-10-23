// lib/frontend/operator/machine_management/operator_machine/widgets/operator_machine_list.dart

import 'package:flutter/material.dart';
import '../controllers/operator_machine_controller.dart';
import 'operator_machine_card.dart';

class OperatorMachineList extends StatelessWidget {
  final OperatorMachineController controller;

  const OperatorMachineList({
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
              controller.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'No machines found matching "${controller.searchQuery}"'
                  : 'No machines assigned to you yet.\nContact your admin for machine assignment.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
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
        return OperatorMachineCard(
          machine: machine,
          controller: controller,
        );
      },
    );
  }
}