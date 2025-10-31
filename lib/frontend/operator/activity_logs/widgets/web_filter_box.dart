// lib/frontend/operator/widgets/web_filter_box.dart
import 'package:flutter/material.dart';

class WebFilterBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String filterValue;
  final VoidCallback? onTap; // ✅ Web callback — no navigation

  const WebFilterBox({
    super.key,
    required this.icon,
    required this.label,
    required this.filterValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.grey[50],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap, // ✅ No Navigator.push — just callback
          hoverColor: Colors.teal,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.teal,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}