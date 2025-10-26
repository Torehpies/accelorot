import 'package:flutter/material.dart';
import '../models/machine_model.dart';
import 'widgets/machine_card.dart';
import 'widgets/machine_detail_dialog.dart';

/// Section widget for displaying and managing machines
class MachineManagementSection extends StatelessWidget {
  final List<MachineModel> machines;
  final VoidCallback? onManageTap;

  const MachineManagementSection({
    super.key,
    required this.machines,
    this.onManageTap,
  });

  void _showMachineDetails(BuildContext context, MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => MachineDetailDialog(machine: machine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMachineList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Machine Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onManageTap,
          child: const Text(
            'Manage >',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMachineList(BuildContext context) {
    if (machines.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No machines available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: machines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < machines.length - 1 ? 12 : 0,
            ),
            child: MachineCard(
              machine: machines[index],
              onTap: () => _showMachineDetails(context, machines[index]),
            ),
          );
        },
      ),
    );
  }
}