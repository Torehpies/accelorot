import 'package:flutter/material.dart';

class StatusFilterHeader extends StatelessWidget {
  final String currentFilter;
  final List<String> options;
  final Function(String) onFilterChanged;

  const StatusFilterHeader({
    super.key,
    required this.currentFilter,
    required this.options,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: currentFilter != 'All' 
                ? const Color(0xFF3B82F6) 
                : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_alt,
            size: 16,
            color: currentFilter != 'All' 
                ? const Color(0xFF3B82F6) 
                : const Color(0xFF6B7280),
          ),
          onSelected: onFilterChanged,
          itemBuilder: (context) {
            return options
                .map((status) => PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          if (currentFilter == status)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          if (currentFilter == status) const SizedBox(width: 8),
                          Text(status),
                        ],
                      ),
                    ))
                .toList();
          },
        ),
      ],
    );
  }
}