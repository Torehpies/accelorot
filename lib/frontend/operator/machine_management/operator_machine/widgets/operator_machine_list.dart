// lib/frontend/operator/machine_management/operator_machine/widgets/operator_machine_list.dart

import 'package:flutter/material.dart';
import '../controllers/operator_machine_controller.dart';
import 'operator_machine_card.dart';

class OperatorMachineList extends StatelessWidget {
  final OperatorMachineController controller;

  const OperatorMachineList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final filteredMachines = controller.filteredMachines;
    final displayedMachines = controller.displayedMachines;

    if (filteredMachines.isEmpty) {
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
                  : 'No machines available in your team.\nContact your admin for machine assignment.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: displayedMachines.length + (controller.hasMoreToLoad ? 1 : 0),
      itemBuilder: (context, index) {
        // Show "Load More" button at the end
        if (index == displayedMachines.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: controller.loadMore,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  'Load More (${controller.remainingCount} remaining)',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          );
        }

        final machine = displayedMachines[index];
        return OperatorMachineCard(machine: machine, controller: controller);
      },
    );
  }
}
