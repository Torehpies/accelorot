// lib/ui/activity_logs/view/web_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/web_responsive_layout.dart';
import '../widgets/web_loading_state.dart';
import '../widgets/web_empty_state.dart';
import '../widgets/web_activity_card.dart';

/// Dashboard screen with preview sections
class WebDashboardScreen extends ConsumerWidget {
  final String? viewingOperatorId;
  final String? focusedMachineId;
  final Function(String)? onViewAll;

  const WebDashboardScreen({
    super.key,
    this.viewingOperatorId,
    this.focusedMachineId,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WebResponsiveLayout(
      wide: (context) => _buildWideLayout(context, ref),
      medium: (context) => _buildMediumLayout(context, ref),
      narrow: (context) => _buildNarrowLayout(context, ref),
    );
  }

  Widget _buildWideLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recent Activity (full width)
          _buildRecentActivitySection(context, ref),
          const SizedBox(height: 24),
          
          // Three columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSubstratePreview(context, ref)),
              const SizedBox(width: 24),
              Expanded(child: _buildAlertsPreview(context, ref)),
              const SizedBox(width: 24),
              Expanded(child: _buildReportsPreview(context, ref)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Cycles (full width)
          _buildCyclesPreview(context, ref),
        ],
      ),
    );
  }

  Widget _buildMediumLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRecentActivitySection(context, ref),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSubstratePreview(context, ref)),
              const SizedBox(width: 20),
              Expanded(child: _buildAlertsPreview(context, ref)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildReportsPreview(context, ref)),
              const SizedBox(width: 20),
              Expanded(child: _buildCyclesPreview(context, ref)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRecentActivitySection(context, ref),
          const SizedBox(height: 20),
          _buildSubstratePreview(context, ref),
          const SizedBox(height: 20),
          _buildAlertsPreview(context, ref),
          const SizedBox(height: 20),
          _buildReportsPreview(context, ref),
          const SizedBox(height: 20),
          _buildCyclesPreview(context, ref),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, WidgetRef ref) {
    final params = ActivityParams(
      screenType: ActivityScreenType.allActivity,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );
    final state = ref.watch(activityViewModelProvider(params));

    return _buildPreviewCard(
      title: 'Recent Activity',
      icon: Icons.history,
      iconColor: Colors.teal,
      isLoading: state.isLoading,
      isEmpty: state.isEmpty,
      items: state.filteredActivities.take(5).toList(),
      onViewAll: null, // No view all for recent
    );
  }

  Widget _buildSubstratePreview(BuildContext context, WidgetRef ref) {
    final params = ActivityParams(
      screenType: ActivityScreenType.substrates,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );
    final state = ref.watch(activityViewModelProvider(params));

    return _buildPreviewCard(
      title: 'Substrate Log',
      icon: Icons.eco,
      iconColor: Colors.green,
      isLoading: state.isLoading,
      isEmpty: state.isEmpty,
      items: state.filteredActivities.take(3).toList(),
      onViewAll: () => onViewAll?.call('substrate'),
    );
  }

  Widget _buildAlertsPreview(BuildContext context, WidgetRef ref) {
    final params = ActivityParams(
      screenType: ActivityScreenType.alerts,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );
    final state = ref.watch(activityViewModelProvider(params));

    return _buildPreviewCard(
      title: 'Recent Alerts',
      icon: Icons.warning,
      iconColor: Colors.orange,
      isLoading: state.isLoading,
      isEmpty: state.isEmpty,
      items: state.filteredActivities.take(3).toList(),
      onViewAll: () => onViewAll?.call('alerts'),
    );
  }

  Widget _buildReportsPreview(BuildContext context, WidgetRef ref) {
    final params = ActivityParams(
      screenType: ActivityScreenType.reports,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );
    final state = ref.watch(activityViewModelProvider(params));

    return _buildPreviewCard(
      title: 'Reports',
      icon: Icons.report_outlined,
      iconColor: Colors.deepPurple,
      isLoading: state.isLoading,
      isEmpty: state.isEmpty,
      items: state.filteredActivities.take(3).toList(),
      onViewAll: () => onViewAll?.call('reports'),
    );
  }

  Widget _buildCyclesPreview(BuildContext context, WidgetRef ref) {
    final params = ActivityParams(
      screenType: ActivityScreenType.cyclesRecom,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );
    final state = ref.watch(activityViewModelProvider(params));

    return _buildPreviewCard(
      title: 'Composting Cycles',
      icon: Icons.auto_awesome,
      iconColor: Colors.blue,
      isLoading: state.isLoading,
      isEmpty: state.isEmpty,
      items: state.filteredActivities.take(3).toList(),
      onViewAll: () => onViewAll?.call('cycles'),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isLoading,
    required bool isEmpty,
    required List items,
    VoidCallback? onViewAll,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 243, 243, 243),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (onViewAll != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.teal, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 243, 243, 243)),
          
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: WebLoadingState(),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: WebEmptyState(
                message: 'No ${title.toLowerCase()}',
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return WebActivityCard(item: items[index]);
              },
            ),
        ],
      ),
    );
  }
}