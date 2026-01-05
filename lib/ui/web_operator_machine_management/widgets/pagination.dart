import 'package:flutter/material.dart';

/// Pagination widget for navigating through machine pages
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canGoNext;
  final bool canGoPrevious;
  final bool isDesktop;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(
        ),
      ),
      child: isDesktop ? _buildDesktopPagination() : _buildMobilePagination(),
    );
  }

  Widget _buildDesktopPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page size selector
        _buildPageSizeSelector(),
        
        // Page navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            _buildNavigationButton(
              icon: Icons.chevron_left,
              enabled: canGoPrevious,
              onTap: onPrevious,
              label: 'Back',
            ),
            const SizedBox(width: 8),

            // Page Numbers
            ..._buildDesktopPageNumbers(),

            const SizedBox(width: 8),

            // Next Button
            _buildNavigationButton(
              icon: Icons.chevron_right,
              enabled: canGoNext,
              onTap: onNext,
              label: 'Next',
            ),
          ],
        ),
        
        // Spacer to balance the layout
        const SizedBox(width: 200),
      ],
    );
  }

  Widget _buildMobilePagination() {
    return Column(
      children: [
        // Page size selector
        _buildPageSizeSelector(),
        const SizedBox(height: 16),
        
        // Page navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            _buildNavigationButton(
              icon: Icons.chevron_left,
              enabled: canGoPrevious,
              onTap: onPrevious,
              label: 'Back',
            ),
            const SizedBox(width: 8),

            // Page Numbers
            ..._buildMobilePageNumbers(),

            const SizedBox(width: 8),

            // Next Button
            _buildNavigationButton(
              icon: Icons.chevron_right,
              enabled: canGoNext,
              onTap: onNext,
              label: 'Next',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageSizeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Show:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<int>(
            value: itemsPerPage,
            underline: const SizedBox(),
            isDense: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
            items: [10, 25, 50, 100].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                onItemsPerPageChanged(newValue);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'per page',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDesktopPageNumbers() {
    final List<Widget> pages = [];
    
    // Calculate which pages to show
    int startPage = 1;
    int endPage = totalPages;
    
    if (totalPages > 5) {
      if (currentPage <= 3) {
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    // Add first page + ellipsis if needed
    if (startPage > 1) {
      pages.add(_buildPageNumber(1));
      if (startPage > 2) {
        pages.add(_buildEllipsis());
      }
    }

    // Add page numbers
    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildPageNumber(i));
    }

    // Add ellipsis + last page if needed
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(_buildEllipsis());
      }
      pages.add(_buildPageNumber(totalPages));
    }

    return pages;
  }

  List<Widget> _buildMobilePageNumbers() {
    return [
      _buildPageNumber(currentPage),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'of $totalPages',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    ];
  }

  Widget _buildPageNumber(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required String label,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.chevron_left && isDesktop)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            Icon(
              icon,
              size: 20,
              color: enabled ? Colors.white : const Color(0xFF9CA3AF),
            ),
            if (icon == Icons.chevron_right && isDesktop)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}