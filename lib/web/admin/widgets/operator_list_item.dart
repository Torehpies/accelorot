// lib/widgets/operator_list_item.dart

import 'package:flutter/material.dart';
import '../models/operator_model.dart';
import '../../utils/theme_constants.dart';

class OperatorListItem extends StatelessWidget {
  final OperatorModel operator;
  final bool isSelected;
  final VoidCallback onTap;

  const OperatorListItem({
    super.key,
    required this.operator,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? ThemeConstants.tealShade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius12),
          border: Border.all(
            color: isSelected ? ThemeConstants.tealShade300 : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacing12,
          vertical: ThemeConstants.spacing10,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: ThemeConstants.avatarSize44,
              height: ThemeConstants.avatarSize44,
              decoration: BoxDecoration(
                color: ThemeConstants.greyShade300,
                borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: ThemeConstants.greyShade600,
                  size: ThemeConstants.iconSize22,
                ),
              ),
            ),
            const SizedBox(width: ThemeConstants.spacing12),
            // Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operator.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ThemeConstants.fontSize14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    operator.email,
                    style: TextStyle(
                      fontSize: ThemeConstants.fontSize12,
                      color: ThemeConstants.greyShade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
