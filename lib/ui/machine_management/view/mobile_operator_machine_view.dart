// lib/ui/machine_management/view/mobile_operator_machine_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/containers/mobile_common_widgets.dart';
import '../../core/widgets/containers/mobile_sliver_header.dart';
import '../../core/widgets/containers/mobile_list_content.dart';
import '../../core/widgets/filters/mobile_status_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/widgets/sample_cards/data_card_skeleton.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';
import '../view_model/mobile_machine_viewmodel.dart';
import '../models/mobile_machine_state.dart';
import '../widgets/operator_machine_card.dart';
import '../bottom_sheets/mobile_operator_machine_view_sheet.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() => _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
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

    if (_teamId != null) {
      ref.read(mobileMachineViewModelProvider.notifier).initialize(_teamId!);
    }

    if (mounted) setState(() {});
  }

  void _showMachineDetails(MachineModel machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileOperatorMachineViewSheet(machine: machine),
    );
  }

  EmptyStateConfig _getEmptyStateConfig(MobileMachineState state) {
    String message;

    switch (state.selectedStatusFilter) {
      case MachineStatusFilter.inactive:
        message = 'No archived machines';
        break;
      case MachineStatusFilter.active:
        message = 'No active machines';
        break;
      case MachineStatusFilter.underMaintenance:
        message = 'No suspended machines';
        break;
      default:
        message = 'No machines available.\nContact your admin for machine assignment.';
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
              ref.read(mobileMachineViewModelProvider.notifier).clearAllFilters();
            }
          : null,
    );
  }

  Widget _buildMachineCard(BuildContext context, MachineModel machine, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OperatorMachineCard(
        machine: machine,
        onTap: () => _showMachineDetails(machine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileMachineViewModelProvider);
    final notifier = ref.read(mobileMachineViewModelProvider.notifier);

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
                MobileStatusFilterButton(
                  currentFilter: state.selectedStatusFilter,
                  onFilterChanged: notifier.setStatusFilter,
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
            const SliverToBoxAdapter(
              child: SizedBox(height: 4),
            ),

            // Content
            MobileListContent<MachineModel>(
              isLoading: state.isLoading,
              isInitialLoad: state.machines.isEmpty,
              hasError: state.hasError,
              errorMessage: state.errorMessage,
              items: state.filteredMachines,
              displayedItems: state.displayedMachines,
              hasMoreToLoad: state.hasMoreToLoad,
              remainingCount: state.remainingCount,
              emptyStateConfig: _getEmptyStateConfig(state),
              onRefresh: () async {
                if (_teamId != null) {
                  await notifier.refresh(_teamId!);
                }
              },
              onLoadMore: notifier.loadMore,
              onRetry: () {
                notifier.clearError();
                if (_teamId != null) notifier.initialize(_teamId!);
              },
              itemBuilder: _buildMachineCard,
              skeletonBuilder: (context, index) => const DataCardSkeleton(),
            ),
          ],
        ),
      ),
    );
  }
}