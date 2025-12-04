import 'package:flutter/material.dart';
import '../view_model/reports_notifier.dart';

class SortDropdown extends StatelessWidget {
  final SortOption sortOption;
  final ValueChanged<SortOption> onChanged;

  const SortDropdown({
    super.key,
    required this.sortOption,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: sortOption,
          icon: Icon(Icons.sort, color: Colors.grey.shade600),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
          ),
          items: [
            DropdownMenuItem(
              value: SortOption.newest,
              child: Row(
                children: [
                  Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Text('Newest'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: SortOption.oldest,
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Text('Oldest'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: SortOption.priorityHighToLow,
              child: Row(
                children: [
                  Icon(Icons.priority_high, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Text('Priority'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}