// lib/ui/core/widgets/filters/mobile_selector_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_text_styles.dart';

/// Generic mobile selector button for entities (Machine, Batch, etc.)
/// Displays as a dropdown with icon, text, and arrow
/// Shows badge dot when a specific item is selected (not "All")
class MobileSelectorButton<T> extends StatefulWidget {
  final IconData icon;
  final String allLabel; // e.g., "All Machines"
  final String? selectedItemId;
  final List<T> items;
  final String Function(T) itemId;
  final String Function(T) displayName;
  final String? Function(T)? statusBadge; // e.g., "Archived", "Completed"
  final ValueChanged<String?> onChanged;
  final bool isLoading;
  final String? emptyMessage; // e.g., "No machines available"

  const MobileSelectorButton({
    super.key,
    required this.icon,
    required this.allLabel,
    required this.selectedItemId,
    required this.items,
    required this.itemId,
    required this.displayName,
    this.statusBadge,
    required this.onChanged,
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  State<MobileSelectorButton<T>> createState() =>
      _MobileSelectorButtonState<T>();
}

class _MobileSelectorButtonState<T> extends State<MobileSelectorButton<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine if a specific item is selected (not "All")
    final isActive = widget.selectedItemId != null;

    // Get display text
    final displayText = _getDisplayText();

    // Colors based on active state
    final iconColor =
        isActive ? AppColors.green100 : AppColors.textSecondary;
    final borderColor = AppColors.grey;
    final borderWidth = 1.5;
    final backgroundColor =
        _isHovered ? AppColors.grey : AppColors.background2;

    final isEmpty = widget.items.isEmpty;
    final isDisabled = isEmpty || widget.isLoading;

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          onLongPress: isActive && !isDisabled ? _showTooltip : null,
          child: Tooltip(
            message: isActive ? displayText : '',
            waitDuration: const Duration(milliseconds: 500),
            child: InkWell(
              onTap: isDisabled ? null : _showFilterMenu,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Icon with optional badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          widget.icon,
                          color: iconColor,
                          size: 20,
                        ),
                        if (isActive)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.green100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: backgroundColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Display text
                    Expanded(
                      child: Text(
                        displayText,
                        style: AppTextStyles.input.copyWith(
                          color: isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dropdown arrow
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDisabled
                          ? AppColors.textSecondary
                          : (isActive ? AppColors.green100 : AppColors.textSecondary),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (widget.items.isEmpty) {
      return widget.emptyMessage ?? 'No items';
    }

    if (widget.selectedItemId == null) {
      return widget.allLabel;
    }

    // Find selected item
    try {
      final selectedItem = widget.items.firstWhere(
        (item) => widget.itemId(item) == widget.selectedItemId,
      );
      return widget.displayName(selectedItem);
    } catch (e) {
      // If selected item not found in list, show "All"
      return widget.allLabel;
    }
  }

  void _showTooltip() {
    HapticFeedback.lightImpact();
  }

  void _showFilterMenu() async {
    if (widget.isLoading || widget.items.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    // Build menu items
    final List<PopupMenuEntry<String?>> menuItems = [];

    // Add "All" option
    menuItems.add(_buildMenuItem(null, widget.allLabel, null));

    // Add all items
    for (final item in widget.items) {
      menuItems.add(_buildMenuItem(
        widget.itemId(item),
        widget.displayName(item),
        widget.statusBadge?.call(item),
      ));
    }

    final String? selected = await showMenu<String?>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      constraints: const BoxConstraints(maxHeight: 400),
      items: menuItems,
    );

    if (selected != null || selected == null && widget.selectedItemId != null) {
      HapticFeedback.selectionClick();
      widget.onChanged(selected);
    }
  }

  PopupMenuItem<String?> _buildMenuItem(
    String? itemId,
    String label,
    String? badge,
  ) {
    final isSelected = widget.selectedItemId == itemId;

    return PopupMenuItem<String?>(
      value: itemId,
      height: 48,
      child: Row(
        children: [
          // Checkmark
          SizedBox(
            width: 24,
            child: isSelected
                ? Icon(Icons.check, size: 18, color: AppColors.green100)
                : null,
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),

          // Badge (e.g., "Archived", "Completed")
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}