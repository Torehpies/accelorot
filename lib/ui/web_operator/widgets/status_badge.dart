import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/utils/format.dart';

typedef StatusStyle = ({Color color, Color textColor});

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final titleCaseStatus = toTitleCase(status);
    final statusStyle = _getStatusStyle(titleCaseStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusStyle.color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        titleCaseStatus,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusStyle.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  StatusStyle _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return (
          color: AppColors.greenBackground,
          textColor: AppColors.greenForeground,
        );
      case 'removed':
        return (
          color: AppColors.redBackground,
          textColor: AppColors.redForeground,
        );
      case 'archived':
        return (
          color: AppColors.yellowBackground,
          textColor: AppColors.yellowForeground,
        );
      default:
        return (
          color: AppColors.grey,
          textColor: AppColors.textPrimary,
        );
    }
  }
}
