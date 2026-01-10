// lib/ui/web_operator/widgets/operator_empty_state.dart

import 'package:flutter/material.dart';
import '../../core/ui/theme_constants.dart';

class OperatorEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isArchived;
  final String searchQuery;

  const OperatorEmptyState({
    super.key,
    required this.isSearching,
    required this.isArchived,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: ThemeConstants.greyShade400,
          ),
          const SizedBox(height: ThemeConstants.spacing16),
          Text(
            isSearching
                ? 'No operators found matching "$searchQuery"'
                : isArchived
                ? 'No archived operators'
                : 'No operators available',
            style: TextStyle(
              color: ThemeConstants.greyShade600,
              fontSize: ThemeConstants.fontSize16,
            ),
          ),
        ],
      ),
    );
  }
}