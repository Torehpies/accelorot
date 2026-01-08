import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.canGoNext,
    required this.onBack,
    required this.onNext,
    required this.onPageSelected,
  });

  final int currentPage;
  final bool canGoNext;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 2).clamp(0, currentPage);
    final pages = List<int>.generate(5, (i) => start + i);

    Widget pageButton(int index) {
      final isActive = index == currentPage;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: OutlinedButton(
          onPressed: () => onPageSelected(index),
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive ? AppColors.green100 : Colors.white,
            foregroundColor: isActive ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: const Size(40, 36),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text('${index + 1}'),
        ),
      );
    }

    Widget navButton(String label, bool enabled, bool back) {
      return OutlinedButton.icon(
        onPressed: enabled ? (back ? onBack : onNext) : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: AppColors.green100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          side: BorderSide(
            color: enabled ? AppColors.green100 : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        icon: Icon(back ? Icons.chevron_left : Icons.chevron_right, size: 18),
        label: Text(label),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        navButton('Back', currentPage > 0, true),
        const SizedBox(width: 4),
        ...pages.map(pageButton),
        const SizedBox(width: 4),
        navButton('Next', canGoNext, false),
      ],
    );
  }
}
