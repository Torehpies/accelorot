import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Sample card widget for machine status
/// Matches the design from reference image 2
class MachineStatusCard extends StatelessWidget {
  final String machineName;
  final String machineId;
  final String assignedUser;
  final String dateCreated;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const MachineStatusCard({
    super.key,
    required this.machineName,
    required this.machineId,
    required this.assignedUser,
    required this.dateCreated,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000), // Black at 8% opacity
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x2622C55E), // AppColors.green100 at 15% opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.precision_manufacturing,
                color: AppColors.green100,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Machine name and status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        machineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Machine ID
                  _buildInfoRow('Machine ID:', machineId),
                  const SizedBox(height: 6),
                  
                  // Assigned user
                  _buildInfoRow('Assigned User:', assignedUser),
                  const SizedBox(height: 6),
                  
                  // Date created
                  _buildInfoRow('Date Created:', dateCreated),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
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
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
