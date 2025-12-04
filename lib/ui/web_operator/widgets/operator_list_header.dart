// lib/ui/web_operator/widgets/operator_list_header.dart

import 'package:flutter/material.dart';
import '../../core/ui/theme_constants.dart';

class OperatorListHeader extends StatelessWidget {
  final bool showArchived;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onBack;

  const OperatorListHeader({
    super.key,
    required this.showArchived,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with optional back button
          Row(
            children: [
              // Add back button when viewing archived
              if (showArchived && onBack != null) ...[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ThemeConstants.tealShade600,
                    size: ThemeConstants.iconSize20,
                  ),
                  onPressed: onBack,
                  tooltip: 'Back to Active Operators',
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeConstants.tealShade50,
                    minimumSize: const Size(36, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.borderRadius8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacing12),
              ],
              Text(
                showArchived ? 'Archived Operators' : 'Active Operators',
                style: TextStyle(
                  fontSize: ThemeConstants.fontSize18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.tealShade600,
                ),
              ),
            ],
          ),
          // Search Bar and Refresh
          Row(
            children: [
              SizedBox(
                width: 250,
                height: 36,
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: ThemeConstants.greyShade500,
                      fontSize: ThemeConstants.fontSize13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ThemeConstants.greyShade600,
                      size: ThemeConstants.iconSize18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.borderRadius10,
                      ),
                      borderSide: BorderSide(
                        color: ThemeConstants.greyShade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.borderRadius10,
                      ),
                      borderSide: BorderSide(
                        color: ThemeConstants.greyShade300,
                      ),
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
                      vertical: 0,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: ThemeConstants.fontSize13),
                ),
              ),
              const SizedBox(width: ThemeConstants.spacing12),
              SizedBox(
                width: 36,
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
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeConstants.greyShade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.borderRadius8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
