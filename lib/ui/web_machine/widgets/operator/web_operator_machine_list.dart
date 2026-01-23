import 'package:flutter/material.dart';
import '../../../../data/models/machine_model.dart';
import 'web_operator_machine_card.dart';

class WebOperatorMachineList extends StatelessWidget {
  final List<MachineModel> machines;
  final bool hasMoreToLoad;
  final int remainingCount;
  final VoidCallback onLoadMore;

  const WebOperatorMachineList({
    super.key,
    required this.machines,
    required this.hasMoreToLoad,
    required this.remainingCount,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 3
                  : constraints.maxWidth > 800
                  ? 2
                  : 1;

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final machine = machines[index];
                  return WebOperatorMachineCard(machine: machine);
                },
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
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Machines Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any machines assigned yet.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
