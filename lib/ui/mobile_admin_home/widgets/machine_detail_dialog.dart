// lib/ui/mobile_admin_home/widgets/machine_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../widgets/status_indicator.dart';

class MachineDetailDialog extends StatelessWidget {
  final MachineModel machine;

  const MachineDetailDialog({super.key, required this.machine});

  String _formatDate(DateTime date) => DateFormat('MMMM d, y').format(date);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Machine Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                StatusIndicator(isArchived: machine.isArchived, showText: true, size: 12),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Machine Name', machine.machineName),
            const SizedBox(height: 16),
            _buildDetailRow('Machine ID', machine.machineId),
            const SizedBox(height: 16),
            _buildDetailRow('Date Added', _formatDate(machine.dateCreated)),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600])),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    ]);
  }
}