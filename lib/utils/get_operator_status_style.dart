import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/status_badge.dart';

StatusStyle getStatusStyle(String status) {
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
      return (color: AppColors.grey, textColor: AppColors.textPrimary);
  }
}
