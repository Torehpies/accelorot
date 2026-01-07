import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';

class StatusDropdown extends StatelessWidget {
  final MachineStatus status;
  final Function(MachineStatus) onChanged;
  final bool enabled;

  const StatusDropdown({
    super.key,
    required this.status,
    required this.onChanged,
    this.enabled = true,
  });

  String _getStatusLabel(MachineStatus status) {
    switch (status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Inactive';
      case MachineStatus.underMaintenance:
        return 'Under Maintenance';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showStatusDialog(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStatusLabel(status),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(BuildContext context) async {
    final result = await showDialog<MachineStatus>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Select Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Options
              _buildStatusOption(
                context,
                MachineStatus.active,
                'Active',
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                context,
                MachineStatus.inactive,
                'Inactive',
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                context,
                MachineStatus.underMaintenance,
                'Under Maintenance',
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  Widget _buildStatusOption(
    BuildContext context,
    MachineStatus statusOption,
    String label,
  ) {
    final isSelected = status == statusOption;

    return InkWell(
      onTap: () => Navigator.pop(context, statusOption),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.grey[400]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}