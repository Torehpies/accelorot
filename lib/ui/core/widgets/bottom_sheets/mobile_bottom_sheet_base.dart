// lib/ui/core/bottom_sheet/mobile_bottom_sheet_base.dart

import 'package:flutter/material.dart';
import 'mobile_bottom_sheet_buttons.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';

class MobileBottomSheetBase extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<BottomSheetAction> actions;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const MobileBottomSheetBase({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    required this.actions,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WebColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? '—' : title,
                        style: WebTextStyles.sectionTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: title.isEmpty
                              ? WebColors.textMuted
                              : WebColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: WebTextStyles.bodyMediumGray.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: WebColors.textSecondary),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: WebColors.cardBorder),

          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: body,
            ),
          ),

          // Footer with action buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MobileBottomSheetButtons(actions: actions),
          ),
        ],
      ),
    );
  }
}