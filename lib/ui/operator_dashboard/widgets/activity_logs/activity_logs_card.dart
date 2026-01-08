// lib/ui/mobile_operator_dashboard/widgets/add_waste/activity_logs_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/activity_providers.dart';
import 'activity_logs_mobile.dart';
import 'activity_logs_web.dart';

/// Main activity logs card that switches between mobile and web layouts
class ActivityLogsCard extends ConsumerWidget {
  final String? focusedMachineId;
  final double? maxHeight;

  const ActivityLogsCard({super.key, this.focusedMachineId, this.maxHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use Table layout for wider screens (Web/Tablet)
        // Use Card layout for narrow screens (Mobile)
        final isWebLayout = constraints.maxWidth > 600;

        if (isWebLayout) {
          return const ActivityLogsWeb();
        }

        // Mobile layout with header outside
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {
                      ref.invalidate(allActivitiesProvider);
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Content
            const Expanded(child: ActivityLogsMobile()),
          ],
        );
      },
    );
  }
}
