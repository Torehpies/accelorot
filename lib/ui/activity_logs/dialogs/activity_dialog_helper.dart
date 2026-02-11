// lib/ui/activity_logs/dialogs/activity_dialog_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/models/report.dart';
import '../../../data/models/substrate.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../view_model/unified_activity_viewmodel.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/themes/web_colors.dart';
import 'report_detail_dialog.dart';
import 'substrate_detail_dialog.dart';
import 'alert_detail_dialog.dart';
import 'cycle_detail_dialog.dart';

/// Helper class to show activity detail dialogs with instant loading from cache
class ActivityDialogHelper {
  /// Show detail dialog for any activity item
  /// Looks up full entity from cache - NO ASYNC LOADING!
  static void show(BuildContext context, WidgetRef ref, ActivityLogItem item) {
    // Get the view model to access cache
    final viewModel = ref.read(unifiedActivityViewModelProvider.notifier);

    // Lookup full entity from cache
    final fullEntity = viewModel.getFullEntity(item);

    // If entity not found in cache (edge case - shouldn't happen)
    if (fullEntity == null) {
      _showErrorDialog(
        context,
        'Entity not found in cache. Please refresh and try again.',
      );
      return;
    }

    // Show appropriate dialog based on entity type
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildDialogContent(fullEntity),
        ),
      ),
    );
  }

  /// Build the appropriate dialog content based on entity type
  static Widget _buildDialogContent(dynamic entity) {
    if (entity is Report) {
      return ReportDetailDialog(report: entity);
    } else if (entity is Substrate) {
      return SubstrateDetailDialog(substrate: entity);
    } else if (entity is Alert) {
      return AlertDetailDialog(alert: entity);
    } else if (entity is CycleRecommendation) {
      return CycleDetailDialog(cycle: entity);
    } else {
      return _ErrorDialog(error: 'Unknown entity type: ${entity.runtimeType}');
    }
  }

  /// Show error dialog for edge cases
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _ErrorDialog(error: message),
        ),
      ),
    );
  }
}

/// Error state dialog - shown if cache lookup fails (edge case)
class _ErrorDialog extends StatelessWidget {
  final String error;

  const _ErrorDialog({required this.error});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Error Loading Details',
      subtitle: 'Unable to fetch information',
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: WebColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: WebColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: WebColors.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: WebColors.error, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
