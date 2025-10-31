import 'package:flutter/material.dart';

/// Reusable status indicator widget showing active/archived status
/// Can be displayed as:
/// - Circle only (for cards)
/// - Circle with text (for detail views)
class StatusIndicator extends StatelessWidget {
  final bool isArchived;
  final bool showText;
  final double size;

  const StatusIndicator({
    super.key,
    required this.isArchived,
    this.showText = false,
    this.size = 12,
  });

  Color get _statusColor => isArchived ? Colors.grey : const Color(0xFF4CAF50);
  String get _statusText => isArchived ? 'Archived' : 'Active';

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return _buildWithText();
    }
    return _buildCircleOnly();
  }

  /// Circle indicator only (for cards)
  Widget _buildCircleOnly() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _statusColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Circle with text label (for detail views)
  Widget _buildWithText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _statusText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isArchived ? Colors.grey[700] : Colors.green[700],
          ),
        ),
      ],
    );
  }
}