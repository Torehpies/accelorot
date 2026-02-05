import 'package:flutter/material.dart';

/// A reusable widget that displays a small labeled info item.
/// Used in ActiveState and similar widgets.
class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final double? fontSize;

  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = fontSize ?? (screenWidth < 1200 ? 11.0 : 13.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: baseFontSize * 0.85,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
