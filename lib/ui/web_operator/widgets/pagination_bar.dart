import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';

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

    Widget buildPageButton(int page, int currentPage) {
      final isActive = page == currentPage;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () => onPageSelected(page),
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.green100 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${page + 1}',
              style: isActive
                  ? WebTextStyles.bodyMedium.copyWith(
                      color: WebColors.cardBackground,
                    )
                  : WebTextStyles.bodyMedium,
            ),
          ),
        ),
      );
    }

    Widget buildNavButton({
      required IconData icon,
      required String label,
      required bool isEnabled,
      required VoidCallback onTap,
      required bool isNext,
    }) {
      return MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            hoverColor: isEnabled
                ? WebColors.inputBackground
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isNext) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: isEnabled
                          ? WebColors.textSecondary
                          : WebColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: WebTextStyles.bodyMedium.copyWith(
                      color: isEnabled
                          ? WebColors.textSecondary
                          : WebColors.textMuted,
                    ),
                  ),
                  if (isNext) ...[
                    const SizedBox(width: 6),
                    Icon(
                      icon,
                      size: 18,
                      color: isEnabled
                          ? WebColors.textSecondary
                          : WebColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildNavButton(
          icon: Icons.chevron_left,
          label: 'Back',
          isEnabled: currentPage > 0,
          onTap: onBack,
          isNext: false,
        ),
        const SizedBox(width: AppSpacing.sm),
        ...pages.map((page) => buildPageButton(page, currentPage)),
        const SizedBox(width: AppSpacing.sm),
        buildNavButton(
          icon: Icons.chevron_right,
          label: 'Next',
          isEnabled: canGoNext,
          onTap: onNext,
          isNext: true,
        ),
      ],
    );
  }
}
