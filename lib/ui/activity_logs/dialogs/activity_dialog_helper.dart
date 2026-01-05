// lib/ui/activity_logs/dialogs/activity_dialog_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/providers/report_providers.dart';
import '../../../data/providers/substrate_providers.dart';
import '../../../data/providers/alert_providers.dart';
import '../../../data/providers/cycle_providers.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/themes/web_colors.dart';
import 'report_detail_dialog.dart';
import 'substrate_detail_dialog.dart';
import 'alert_detail_dialog.dart';
import 'cycle_detail_dialog.dart';

/// Helper class to show activity detail dialogs with automatic data fetching
class ActivityDialogHelper {
  /// Show detail dialog for any activity item
  static void show(
    BuildContext context,
    WidgetRef ref,
    ActivityLogItem item,
  ) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _DialogContentLoader(item: item),
        ),
      ),
    );
  }
}

/// Internal widget that handles async loading and state management
class _DialogContentLoader extends ConsumerWidget {
  final ActivityLogItem item;

  const _DialogContentLoader({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Widget>(
      future: _loadFullData(ref),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingDialog();
        }

        // Error state
        if (snapshot.hasError) {
          return _ErrorDialog(error: snapshot.error.toString());
        }

        // Success state - return the actual detail dialog
        return snapshot.data ?? const _ErrorDialog(error: 'Unknown error occurred');
      },
    );
  }

  /// Load full data based on activity type
  /// Routes to appropriate repository and returns correct dialog
  Future<Widget> _loadFullData(WidgetRef ref) async {
    try {
      switch (item.type) {
        case ActivityType.report:
          // Reports need both machineId and reportId
          if (item.machineId == null) {
            throw Exception('Report is missing machine ID');
          }
          
          final repo = ref.read(reportRepositoryProvider);
          final report = await repo.getReportById(item.machineId!, item.id);
          
          if (report == null) {
            throw Exception('Report not found or has been deleted');
          }
          
          return ReportDetailDialog(report: report);

        case ActivityType.substrate:
          final repo = ref.read(substrateRepositoryProvider);
          final substrate = await repo.getSubstrate(item.id);
          
          if (substrate == null) {
            throw Exception('Substrate not found or has been deleted');
          }
          
          return SubstrateDetailDialog(substrate: substrate);

        case ActivityType.alert:
          final repo = ref.read(alertRepositoryProvider);
          final alert = await repo.getAlert(item.id);
          
          if (alert == null) {
            throw Exception('Alert not found or has been deleted');
          }
          
          return AlertDetailDialog(alert: alert);

        case ActivityType.cycle:
          final repo = ref.read(cycleRepositoryProvider);
          final cycle = await repo.getCycle(item.id);
          
          if (cycle == null) {
            throw Exception('Cycle not found or has been deleted');
          }
          
          return CycleDetailDialog(cycle: cycle);
      }
    } catch (e) {
      // Catch any errors during data fetching
      return _ErrorDialog(error: e.toString());
    }
  }
}

/// Loading state dialog - shown while fetching data
class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Loading Details',
      subtitle: 'Fetching information...',
      canClose: false, // Prevent closing during load
      content: const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: WebColors.tealAccent,
            strokeWidth: 3,
          ),
        ),
      ),
      actions: const [],
    );
  }
}

/// Error state dialog - shown if data fetch fails
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
            const Icon(
              Icons.error_outline,
              color: WebColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: WebColors.error,
                  fontSize: 14,
                ),
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