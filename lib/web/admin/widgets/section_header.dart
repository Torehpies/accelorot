// lib/web/widgets/section_header.dart

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapManage;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onTapManage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        TextButton(
          onPressed: onTapManage,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            children: [
              Text(
                'Manage',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 13, color: Colors.teal),
            ],
          ),
        ),
      ],
    );
  }
}