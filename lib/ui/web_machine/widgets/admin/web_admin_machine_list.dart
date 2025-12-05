import 'package:flutter/material.dart';
import '../../../../data/models/machine_model.dart';
import 'web_admin_machine_card.dart';

class WebAdminMachineList extends StatelessWidget {
  final List<MachineModel> machines;
  final bool hasMoreToLoad;
  final int remainingCount;
  final VoidCallback onLoadMore;
  final String teamId;

  const WebAdminMachineList({
    super.key,
    required this.machines,
    required this.hasMoreToLoad,
    required this.remainingCount,
    required this.onLoadMore,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No machines available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              return WebAdminMachineCard(
                machine: machines[index],
                teamId: teamId,
              );
            },
          ),
        ),
        if (hasMoreToLoad)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text('Load More ($remainingCount remaining)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}