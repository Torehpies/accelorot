import 'package:flutter/material.dart';
import '../models/machines_view_model.dart';

/// Table widget to display machines in desktop/tablet view
class MachineTableWidget extends StatelessWidget {
  final List<Machine> machines;
  final Function(String) onMachineAction;

  const MachineTableWidget({
    super.key,
    required this.machines,
    required this.onMachineAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: _buildColumnHeader('ID')),
              Expanded(flex: 2, child: _buildColumnHeader('Name')),
              Expanded(flex: 2, child: _buildColumnHeader('Status')),
              const SizedBox(
                width: 80,
                child: Text(
                  'Actions',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
                // Table Rows
        Expanded(
          child: machines.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: machines.length,
                  itemBuilder: (context, index) {
                    return _buildTableRow(machines[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildColumnHeader(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.unfold_more,
          size: 16,
          color: Color(0xFF9CA3AF),
        ),
      ],
    );
  }

  Widget _buildTableRow(Machine machine) {
  return InkWell(
    onTap: () => onMachineAction(machine.id),
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              machine.id,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${machine.firstName} ${machine.lastName}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(machine.status),
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                color: const Color(0xFF6B7280),
                onPressed: () => onMachineAction(machine.id),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusBadge(String status) {
  Color bgColor;
  Color textColor;

  switch (status.toLowerCase()) {
    case 'active':
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF065F46);
      break;
    case 'inactive':
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
      break;
    case 'suspended':
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
      break;
    default:
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20), // more pill-shaped
    ),
    child: Text(
      status,
      textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }
}