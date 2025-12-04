// lib/ui/activity_logs/widgets/web_activity_search_bar.dart

import 'package:flutter/material.dart';

/// Search input with clear button
class WebActivitySearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const WebActivitySearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search activities...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}