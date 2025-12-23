import 'package:flutter/material.dart';

/// Pagination widget for navigating through machine pages
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canGoNext;
  final bool canGoPrevious;
  final bool isDesktop;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
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
          if (isDesktop) ..._buildDesktopPageNumbers() else ..._buildMobilePageNumbers(),

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
    );
  }

  List<Widget> _buildDesktopPageNumbers() {
    final List<Widget> pages = [];
    
    // Show up to 5 pages
    for (int i = 1; i <= 5 && i <= totalPages; i++) {
      pages.add(_buildPageNumber(i));
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