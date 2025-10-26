import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../widgets/status_indicator.dart';

/// Card widget displaying machine information
/// Shows machine icon placeholder, name, and status indicator
class MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback? onTap;

  const MachineCard({
    super.key,
    required this.machine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade600,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMachineIcon(),
                const SizedBox(height: 8),
                _buildName(),
              ],
            ),
            // Status indicator in top-right corner
            Positioned(
              top: 4,
              right: 4,
              child: StatusIndicator(
                isArchived: machine.isArchived,
                showText: false,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.precision_manufacturing,
        size: 40,
        color: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        machine.machineName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}