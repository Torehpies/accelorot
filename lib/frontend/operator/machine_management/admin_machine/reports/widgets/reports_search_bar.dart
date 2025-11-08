// lib/frontend/operator/machine_management/reports/widgets/reports_search_bar.dart

import 'package:flutter/material.dart';
import '../controllers/reports_controller.dart';

class ReportsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final FocusNode focusNode;
  final ReportsController reportsController;

  const ReportsSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onClear,
    required this.focusNode,
    required this.reportsController,
  });

  void _clearSearch() {
    controller.clear();
    onClear();
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search TextField
        Expanded(
          child: Container(
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
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search reports....',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 28,
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}