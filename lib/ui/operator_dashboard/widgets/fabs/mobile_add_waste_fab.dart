// lib/ui/operator_dashboard/widgets/fabs/mobile_add_waste_fab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../quick_actions/quick_actions_sheet.dart';
import '../../../../data/providers/activity_providers.dart';
import '../../../../data/providers/batch_providers.dart';
import '../../../core/themes/app_theme.dart';

class MobileAddWasteFAB extends ConsumerWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;
  final VoidCallback? onSuccess;

  const MobileAddWasteFAB({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
    this.onSuccess,
  });

  Future<void> _handleFABPress(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickActionsSheet(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 16),
      child: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          onPressed: () => _handleFABPress(context, ref),
          backgroundColor: AppColors.green100,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}