// lib/ui/core/widgets/filters/search_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

/// Reusable search field with icon and consistent styling
class SearchField extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String> onChanged;
  final double? width;
  final bool isLoading;

  const SearchField({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 150,
        maxWidth: width ?? 220,
      ),
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: WebColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: WebColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: WebColors.textLabel, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  enabled: !isLoading,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: WebTextStyles.bodyMediumGray,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: WebTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
