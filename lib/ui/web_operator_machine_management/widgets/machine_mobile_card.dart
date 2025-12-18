import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';

class MachineMobileCardWidget extends StatelessWidget {
  final List<MachineModel> machines;
  final Function(String) onMachineAction;

  const MachineMobileCardWidget({
    super.key,
    required this.machines,
    required this.onMachineAction,
  });

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        return _buildMachineCard(machines[index]);
      },
    );
  }

  Widget _buildMachineCard(MachineModel machine) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      child: InkWell(
        onTap: () => onMachineAction(machine.machineId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      machine.machineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(machine.isArchived),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Machine ID
              _buildInfoRow(
                Icons.tag,
                'ID',
                machine.machineId,
              ),
              
              const SizedBox(height: 8),
              
              // Date Created
              _buildInfoRow(
                Icons.calendar_today,
                'Created',
                dateFormat.format(machine.dateCreated),
              ),
              
              // Current Batch ID if available
              if (machine.currentBatchId != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.inventory_2_outlined,
                  'Current Batch',
                  machine.currentBatchId!,
                ),
              ],
              
              // Last Modified if available
              if (machine.lastModified != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.update,
                  'Modified',
                  dateFormat.format(machine.lastModified!),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => onMachineAction(machine.machineId),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isArchived) {
    final status = isArchived ? 'Archived' : 'Active';
    final bgColor = isArchived 
        ? const Color(0xFFFEF3C7) 
        : const Color(0xFFD1FAE5);
    final textColor = isArchived 
        ? const Color(0xFF92400E) 
        : const Color(0xFF065F46);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.precision_manufacturing_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'No machines found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}