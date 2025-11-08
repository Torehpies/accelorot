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
    final filteredMachines = controller.filteredMachines;
    final displayedMachines = controller.displayedMachines;

    if (filteredMachines.isEmpty) {
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
        return AdminMachineCard(
          machine: machine,
          controller: controller,
        );
      },
    );
  }
}