import 'package:flutter/material.dart';

class WebOperatorSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const WebOperatorSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 36,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.teal, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              isDense: true,
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          height: 36,
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal, size: 20),
            onPressed: onRefresh,
            tooltip: 'Refresh',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
