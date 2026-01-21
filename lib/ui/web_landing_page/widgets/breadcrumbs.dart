// lib/ui/landing_page/widgets/breadcrumbs.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
  });
}

class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const Breadcrumbs({
    super.key,
    required this.items,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.md,
          ),
      color: backgroundColor ?? Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) _buildSeparator(),
            _BreadcrumbItemWidget(
              item: items[i],
              isLast: i == items.length - 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: WebColors.textMuted,
      ),
    );
  }
}

class _BreadcrumbItemWidget extends StatefulWidget {
  final BreadcrumbItem item;
  final bool isLast;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
  });

  @override
  State<_BreadcrumbItemWidget> createState() => _BreadcrumbItemWidgetState();
}

class _BreadcrumbItemWidgetState extends State<_BreadcrumbItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.item.onTap != null && !widget.isLast;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isClickable ? widget.item.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _isHovered && isClickable
                ? WebColors.greenAccent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 16,
                  color: widget.isLast
                      ? WebColors.greenAccent
                      : _isHovered && isClickable
                          ? WebColors.greenAccent
                          : WebColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: WebTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: widget.isLast ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isLast
                      ? WebColors.greenAccent
                      : _isHovered && isClickable
                          ? WebColors.greenAccent
                          : WebColors.textSecondary,
                ),
                child: Text(widget.item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sectional Breadcrumb for Landing Page (shows current section)
class SectionBreadcrumbs extends StatelessWidget {
  final String currentSection;
  final List<String> sections;
  final Function(String)? onSectionTap;
  final ScrollController? scrollController;

  const SectionBreadcrumbs({
    super.key,
    required this.currentSection,
    required this.sections,
    this.onSectionTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: WebColors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: sections.map((section) {
          final isActive = section == currentSection;
          return _SectionChip(
            label: section,
            isActive: isActive,
            onTap: onSectionTap != null ? () => onSectionTap!(section) : null,
          );
        }).toList(),
      ),
    );
  }
}

class _SectionChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SectionChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_SectionChip> createState() => _SectionChipState();
}

class _SectionChipState extends State<_SectionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? WebColors.greenAccent
                : _isHovered
                    ? WebColors.greenAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive || _isHovered
                  ? WebColors.greenAccent
                  : WebColors.cardBorder,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: WebTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              color: widget.isActive
                  ? Colors.white
                  : _isHovered
                      ? WebColors.greenAccent
                      : WebColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
