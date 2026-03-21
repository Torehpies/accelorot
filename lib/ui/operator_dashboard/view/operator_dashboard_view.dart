// lib/ui/operator_dashboard/view/operator_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/containers/mobile_common_widgets.dart';
import '../../core/widgets/containers/mobile_sliver_header.dart';
import '../../core/widgets/containers/mobile_list_content.dart';
import '../../core/widgets/filters/mobile_drum_status_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../widgets/operator_machine_card_skeleton.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';
import '../view_model/operator_dashboard_viewmodel.dart';
import '../models/operator_dashboard_state.dart';
//import '../../activity_logs/models/activity_common.dart';
import '../../machine_detail_screen/view/machine_detail_screen.dart';

import '../widgets/operator_machine_card.dart';

class OperatorDashboardView extends ConsumerStatefulWidget {
  const OperatorDashboardView({super.key});

  @override
  ConsumerState<OperatorDashboardView> createState() =>
      _OperatorDashboardViewState();
}

class _OperatorDashboardViewState extends ConsumerState<OperatorDashboardView> {
  String? _teamId;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTeamIdAndInit() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    _teamId = userData?['teamId'] as String?;

    if (!mounted) return;

    if (_teamId != null) {
      final notifier = ref.read(operatorDashboardViewModelProvider.notifier);
      // Only initialize once — ViewModel's initialize() is a no-op if already loaded.
      notifier.initialize(_teamId!);
    }
  }

  void _showMachineDetails(MachineModel machine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MachineDetailScreen(machine: machine),
      ),
    );
  }

  EmptyStateConfig _getEmptyStateConfig(OperatorDashboardState state) {
    String message;

    switch (state.selectedDrumFilter) {
      case DrumStatusFilter.all:
        message =
            'No machines available.\nContact your admin for machine assignment.';
        break;
      case DrumStatusFilter.empty:
        message = 'No empty machines.';
        break;
      case DrumStatusFilter.running:
        message = 'No running machines.';
        break;
      case DrumStatusFilter.rest:
        message = 'No resting machines.';
        break;
      case DrumStatusFilter.alert:
        message = 'No machines with alerts.';
        break;
    }

    if (state.hasActiveFilters) {
      message = 'No machines match your filters';
    }

    return EmptyStateConfig(
      icon: Icons.inbox_outlined,
      message: message,
      actionLabel: state.hasActiveFilters ? 'Clear All Filters' : null,
      onAction: state.hasActiveFilters
          ? () {
              ref
                  .read(operatorDashboardViewModelProvider.notifier)
                  .clearAllFilters();
            }
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildMachineCard(
    BuildContext context,
    MachineModel machine,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: OperatorMachineCard(
        machine: machine,
        onTap: () => _showMachineDetails(machine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorDashboardViewModelProvider);
    final notifier = ref.read(operatorDashboardViewModelProvider.notifier);

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_teamId != null) {
            await notifier.refresh(_teamId!);
          }
        },
        color: AppColors.green100,
        child: CustomScrollView(
          slivers: [
            // Header with search + filters
            MobileSliverHeader(
              title: 'My Machines',
              showAddButton: false, // Operators cannot add machines
              searchConfig: SearchBarConfig(
                onSearchChanged: notifier.setSearchQuery,
                searchHint: 'Search machines...',
                isLoading: state.isLoading,
                searchFocusNode: _searchFocusNode,
              ),
              filterWidgets: [
                MobileDrumStatusFilterButton(
                  currentFilter: state.selectedDrumFilter,
                  onFilterChanged: notifier.setDrumFilter,
                  isLoading: state.isLoading,
                ),
                const SizedBox(width: 8),
                MobileDateFilterButton(
                  onFilterChanged: notifier.setDateFilter,
                  isLoading: state.isLoading,
                ),
              ],
            ),

            // Top padding for breathing room
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Content
            MobileListContent<MachineModel>(
              isLoading: state.isLoading,
              isInitialLoad: state.machines.isEmpty && !state.hasError,
              hasError: state.hasError,
              errorMessage: state.errorMessage,
              items: state.filteredMachines,
              displayedItems: state.filteredMachines, // Show all
              hasMoreToLoad: false, // Disable load more
              remainingCount: 0,
              emptyStateConfig: _getEmptyStateConfig(state),
              onRefresh: () async {
                if (_teamId != null) {
                  await notifier.refresh(_teamId!);
                }
              },
              onLoadMore: () {}, // No action
              onRetry: () {
                notifier.clearError();
                if (_teamId != null) notifier.initialize(_teamId!);
              },
              itemBuilder: _buildMachineCard,
              skeletonBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: OperatorMachineCardSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
