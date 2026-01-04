import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import 'machine_details_view.dart';

class AdminMachineCard extends ConsumerWidget {
  final MachineModel machine;
  final String teamId;

  const AdminMachineCard({
    super.key,
    required this.machine,
    required this.teamId,
  });

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MachineDetailsView(
          machine: machine,
          teamId: teamId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM-dd-yyyy').format(machine.dateCreated);
    final isArchived = machine.isArchived;

    String statusLabel;
    Color statusColor;
    Color statusBgColor;

    if (isArchived) {
      statusLabel = 'Archived';
      statusColor = const Color(0xFFEF5350);
      statusBgColor = const Color(0xFFFFEBEE);
    } else {
      switch (machine.status) {
        case MachineStatus.active:
          statusLabel = 'Active';
          statusColor = const Color(0xFF4CAF50);
          statusBgColor = const Color(0xFFE8F5E9);
          break;
        case MachineStatus.inactive:
          statusLabel = 'Inactive';
          statusColor = const Color(0xFFFFA726);
          statusBgColor = const Color(0xFFFFF3E0);
          break;
        case MachineStatus.underMaintenance:
          statusLabel = 'Under Maintenance';
          statusColor = const Color(0xFFEF5350);
          statusBgColor = const Color(0xFFFFEBEE);
          break;
      }
    }

    return InkWell(
      onTap: () => _navigateToDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          minHeight: 140,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine Icon
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0x264CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.precision_manufacturing,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Machine Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          machine.machineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Machine ID:', machine.machineId),
                  const SizedBox(height: 6),
                  _buildInfoRow('Assigned User:', 'All Team Members'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Date Created:', dateStr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}