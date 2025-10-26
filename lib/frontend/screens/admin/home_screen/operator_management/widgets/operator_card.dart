import 'package:flutter/material.dart';
import '../../models/operator_model.dart';
import '../../widgets/status_indicator.dart';

/// Card widget displaying operator information
/// Shows profile placeholder, name, and status indicator
class OperatorCard extends StatelessWidget {
  final OperatorModel operator;
  final VoidCallback? onTap;

  const OperatorCard({
    super.key,
    required this.operator,
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
            color: const Color(0xFF4CAF50),
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
                _buildAvatar(),
                const SizedBox(height: 8),
                _buildName(),
              ],
            ),
            // Status indicator in top-right corner
            Positioned(
              top: 4,
              right: 4,
              child: StatusIndicator(
                isArchived: operator.isArchived,
                showText: false,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        operator.name,
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