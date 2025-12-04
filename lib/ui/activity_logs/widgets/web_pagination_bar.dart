// lib/ui/activity_logs/widgets/web_pagination_bar.dart

import 'package:flutter/material.dart';

/// Pagination controls with page numbers
class WebPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const WebPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
        ),
        const SizedBox(width: 8),
        ...List.generate(
          totalPages > 5 ? 5 : totalPages,
          (index) {
            int pageNumber;
            if (totalPages <= 5) {
              pageNumber = index + 1;
            } else if (currentPage <= 3) {
              pageNumber = index + 1;
            } else if (currentPage >= totalPages - 2) {
              pageNumber = totalPages - 4 + index;
            } else {
              pageNumber = currentPage - 2 + index;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () => onPageChanged(pageNumber),
                style: TextButton.styleFrom(
                  backgroundColor: currentPage == pageNumber
                      ? Colors.teal
                      : Colors.grey[200],
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  '$pageNumber',
                  style: TextStyle(
                    color: currentPage == pageNumber
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}