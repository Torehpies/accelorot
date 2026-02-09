import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/mobile_common_widgets.dart';
import '../../core/widgets/mobile_list_header.dart';
import '../../core/widgets/mobile_list_content.dart';
import '../../core/widgets/data_card.dart';
import '../../core/widgets/filters/mobile_status_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/widgets/sample_cards/data_card_skeleton.dart';
import '../../core/dialog/mobile_confirmation_dialog.dart';
import '../../core/toast/mobile_toast_service.dart';
import '../../core/toast/toast_type.dart';
import '../helpers/machine_status_helper.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/sess_service.dart';
import '../view_model/mobile_machine_viewmodel.dart';
import '../models/mobile_machine_state.dart';
import '../bottom_sheets/mobile_admin_machine_view_sheet.dart';
import '../bottom_sheets/mobile_admin_machine_edit_sheet.dart';
import '../bottom_sheets/mobile_admin_machine_add_sheet.dart';

class AdminMachineView extends ConsumerStatefulWidget {
  const AdminMachineView({super.key});

  @override
  ConsumerState<AdminMachineView> createState() => _AdminMachineViewState();
}

class _AdminMachineViewState extends ConsumerState<AdminMachineView> {
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
      builder: (context) => MobileAdminMachineViewSheet(
        machine: machine,
        onEdit: () {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) _showEditSheet(machine);
          });
        },
        onArchive: () {
          Navigator.pop(context);
          _handleArchive(machine);
        },
      ),
    );
  }

  void _showEditSheet(MachineModel machine) {
    if (_teamId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => MobileAdminMachineEditSheet(
        machine: machine,
        teamId: _teamId!,
        onUpdate: ref.read(mobileMachineViewModelProvider.notifier).updateMachine,
      ),
    );
  }

  void _showAddSheet() {
    if (_teamId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => MobileAdminMachineAddSheet(
        teamId: _teamId!,
        onCreate: ({required String machineId, required String machineName}) =>
            ref.read(mobileMachineViewModelProvider.notifier).addMachine(
                  teamId: _teamId!,
                  machineId: machineId,
                  machineName: machineName,
                  assignedUserIds: [],
                ),
      ),
    );
  }

  Future<void> _handleArchive(MachineModel machine) async {
    if (_teamId == null) return;

    final result = await MobileConfirmationDialog.show(
      context,
      title: 'Archive Machine',
      message: 'Are you sure you want to archive "${machine.machineName}"?',
      confirmLabel: 'Archive',
    );

    if (result == ConfirmResult.confirmed && mounted) {
      try {
        await ref
            .read(mobileMachineViewModelProvider.notifier)
            .archiveMachine(_teamId!, machine.machineId);

        if (mounted) {
          MobileToastService.show(
            context,
            message: 'Machine archived successfully',
            type: ToastType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          MobileToastService.show(
            context,
            message: 'Failed to archive machine',
            type: ToastType.error,
          );
        }
      }
    }
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
        message = 'No machines available';
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
      child: DataCard<MachineModel>(
        data: machine,
        icon: Icons.precision_manufacturing,
        iconBgColor: machine.iconColor,
        title: machine.machineName,
        description: machine.cardDescription,
        category: machine.statusLabel,
        status: 'Created on ${machine.formattedDateCreated}',
        userName: 'All Team Members',
        statusColor: machine.statusBgColor,
        statusTextColor: const Color(0xFF424242),
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileListHeader(
          title: 'Machine List',
          showAddButton: true,
          onAddPressed: _showAddSheet,
          addButtonColor: AppColors.green100,
          addButtonLabel: 'Add Machine',
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
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MobileListContent<MachineModel>(
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
        ),
      ),
    );
  }
}