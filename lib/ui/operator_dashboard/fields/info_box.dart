// lib/ui/operator_dashboard/fields/info_box.dart

import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String text;
  final MaterialColor color;
  final String emoji;

  const InfoBox({
    super.key,
    required this.text,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color[100]!),
      ),
      child: Text(
        '$emoji $text',
        style: TextStyle(
          fontSize: 12,
          color: color[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
