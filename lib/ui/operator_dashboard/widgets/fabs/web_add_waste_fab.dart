// lib/ui/operator_dashboard/widgets/fabs/web_add_waste_fab.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../quick_actions/quick_actions_dialog.dart';
import '../../../core/themes/web_colors.dart';
import '../../../../data/providers/activity_providers.dart';
import '../../../../data/providers/batch_providers.dart';

class WebAddWasteFAB extends ConsumerWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;
  final VoidCallback? onSuccess;

  const WebAddWasteFAB({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
    this.onSuccess,
  });

  Future<void> _handleFABPress(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => QuickActionsDialog(
        preSelectedMachineId: preSelectedMachineId,
        preSelectedBatchId: preSelectedBatchId,
      ),
    );

    if (result == true && context.mounted) {
      // Invalidate providers to refresh data
      ref.invalidate(allActivitiesProvider);
      ref.invalidate(userTeamBatchesProvider);

      // Call success callback if provided
      if (onSuccess != null) {
        onSuccess!();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _handleFABPress(context, ref),
      backgroundColor: AppColors.green100,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }
}