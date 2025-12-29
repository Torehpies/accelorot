// lib/ui/mobile_admin_home/widgets/machine_management_section.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import 'machine_card.dart';
import 'machine_detail_dialog.dart';

class MachineManagementSection extends StatelessWidget {
  final List<MachineModel> machines;
  final VoidCallback onManageTap;

  const MachineManagementSection({
    super.key,
    required this.machines,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Machines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onManageTap, child: const Text('Manage >', style: TextStyle(color: Colors.teal))),
        ],
      ),
      const SizedBox(height: 12),
      if (machines.isEmpty)
        const Center(child: Text('No machines yet'))
      else
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final m = machines[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MachineCard(machine: m, onTap: () => _showDetail(context, m)),
              );
            },
          ),
        ),
    ]);
  }

  void _showDetail(BuildContext context, MachineModel machine) {
    showDialog(context: context, builder: (_) => MachineDetailDialog(machine: machine));
  }
}