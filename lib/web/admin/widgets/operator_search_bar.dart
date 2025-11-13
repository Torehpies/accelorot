// lib/widgets/operator_search_bar.dart

import 'package:flutter/material.dart';
import '../../utils/theme_constants.dart';

class OperatorSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const OperatorSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 36,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: ThemeConstants.greyShade500),
              prefixIcon: Icon(
                Icons.search,
                color: ThemeConstants.greyShade600,
                size: ThemeConstants.iconSize20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ThemeConstants.borderRadius10,
                ),
                borderSide: BorderSide(color: ThemeConstants.greyShade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ThemeConstants.borderRadius10,
                ),
                borderSide: BorderSide(color: ThemeConstants.greyShade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ThemeConstants.borderRadius10,
                ),
                borderSide: BorderSide(
                  color: ThemeConstants.tealShade600,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.spacing12,
                vertical: 3,
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: ThemeConstants.spacing12),
        SizedBox(
          width: 40,
          height: 36,
          child: IconButton(
            icon: Icon(
              Icons.refresh,
              color: ThemeConstants.tealShade600,
              size: ThemeConstants.iconSize20,
            ),
            onPressed: onRefresh,
            tooltip: 'Refresh',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
