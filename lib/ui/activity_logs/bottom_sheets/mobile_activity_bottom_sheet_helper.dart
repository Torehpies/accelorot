// lib/ui/activity_logs/bottom_sheets/mobile_activity_bottom_sheet_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/models/report.dart';
import '../../../data/models/substrate.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../view_model/unified_activity_viewmodel.dart';
import 'mobile_report_detail_sheet.dart';
import 'mobile_substrate_detail_sheet.dart';
import 'mobile_alert_detail_sheet.dart';
import 'mobile_cycle_detail_sheet.dart';

/// Mobile counterpart to ActivityDialogHelper.
/// Same cache lookup logic — different presentation layer (bottom sheet vs dialog).
class MobileActivityBottomSheetHelper {
  /// Show detail bottom sheet for any activity item.
  /// Looks up full entity from cache — no async loading.
  static void show(BuildContext context, WidgetRef ref, ActivityLogItem item) {
    final viewModel = ref.read(unifiedActivityViewModelProvider.notifier);
    final fullEntity = viewModel.getFullEntity(item);

    if (fullEntity == null) {
      _showErrorSheet(
        context,
        'Entity not found in cache. Please refresh and try again.',
      );
      return;
    }

    final sheet = _buildSheetContent(fullEntity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  /// Build the appropriate sheet based on entity type
  static Widget _buildSheetContent(dynamic entity) {
    if (entity is Report) {
      return MobileReportDetailSheet(report: entity);
    } else if (entity is Substrate) {
      return MobileSubstrateDetailSheet(substrate: entity);
    } else if (entity is Alert) {
      return MobileAlertDetailSheet(alert: entity);
    } else if (entity is CycleRecommendation) {
      return MobileCycleDetailSheet(cycle: entity);
    } else {
      return _MobileErrorSheet(
        error: 'Unknown entity type: ${entity.runtimeType}',
      );
    }
  }

  /// Show error sheet for edge cases (cache miss)
  static void _showErrorSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MobileErrorSheet(error: message),
    );
  }
}

/// Error sheet — shown if cache lookup fails (edge case, mirrors _ErrorDialog)
class _MobileErrorSheet extends StatelessWidget {
  final String error;

  const _MobileErrorSheet({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Loading Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}