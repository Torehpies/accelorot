// lib/ui/machine_management/view/web_admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/toast/toast_service.dart';
import '../view_model/machine_viewmodel.dart';
import '../new_widgets/web_stats_row.dart';
import '../new_widgets/web_admin_table_container.dart';
import '../dialogs/web_admin_view_details_dialog.dart';
import '../dialogs/web_admin_edit_dialog.dart';
import '../dialogs/web_admin_add_dialog.dart';
import '../models/machine_state.dart';
import '../../core/widgets/web_base_container.dart';

class WebAdminMachineScreen extends ConsumerWidget {
  const WebAdminMachineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MachineState state = ref.watch(machineViewModelProvider);
    final notifier = ref.read(machineViewModelProvider.notifier);

    return WebScaffoldContainer(
      child: state.errorMessage != null && !state.isLoading
          ? WebErrorState(
              message: state.errorMessage!,
              onRetry: () => ref.invalidate(machineViewModelProvider),
            )
          : WebContentContainer(
              child: WebStatsTableLayout(
                statsRow: const MachineStatsRow(),
                table: WebAdminTableContainer(
                  machines: state.paginatedMachines,
                  isLoading: state.isLoading,
                  selectedStatusFilter: state.selectedStatusFilter,
                  searchQuery: state.searchQuery,
                  sortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  itemsPerPage: state.itemsPerPage,
                  totalItems: state.filteredMachines.length,
                  onStatusFilterChanged: notifier.onStatusFilterChanged,
                  onDateFilterChanged: notifier.onDateFilterChanged,
                  onSearchChanged: notifier.onSearchChanged,
                  onSort: notifier.onSort,
                  onEdit: (machine) =>
                      _showEditDialog(context, machine, notifier),
                  onView: (machine) =>
                      _showViewDetailsDialog(context, machine, notifier),
                  onPageChanged: notifier.onPageChanged,
                  onItemsPerPageChanged: notifier.onItemsPerPageChanged,
                  onAddMachine: () => _showAddMachineDialog(context, notifier),
                ),
              ),
            ),
    );
  }

  void _showAddMachineDialog(BuildContext context, MachineViewModel notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: false, // Prevent closing while creating
      builder: (context) => WebAdminAddDialog(
        onCreate:
            ({required String machineId, required String machineName}) async {
              await notifier.addMachine(
                machineId: machineId,
                machineName: machineName,
                assignedUserIds: [],
              );
            },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    MachineModel machine,
    MachineViewModel notifier,
  ) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: false, // Prevent closing while editing
      builder: (context) => WebAdminEditDialog(
        machine: machine,
        onUpdate:
            ({required String machineId, required String machineName}) async {
              await notifier.updateMachine(
                machineId: machineId,
                machineName: machineName,
              );
            },
      ),
    );
  }

  void _showViewDetailsDialog(
    BuildContext context,
    MachineModel machine,
    MachineViewModel notifier,
  ) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => WebAdminViewDetailsDialog(
        machine: machine,
        onArchive: () => _handleArchive(context, machine, notifier),
      ),
    );
  }

  Future<void> _handleArchive(
    BuildContext context,
    MachineModel machine,
    MachineViewModel notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: WebColors.cardBackground,
        title: Text(
          'Archive Machine',
          style: WebTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Are you sure you want to archive "${machine.machineName}"?',
          style: WebTextStyles.bodyMediumGray,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: WebTextStyles.bodyMedium.copyWith(
                color: WebColors.textLabel,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.error,
              foregroundColor: WebColors.buttonText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await notifier.archiveMachine(machine.machineId);
        if (context.mounted) {
          ToastService.show(context, message: 'Machine archived successfully');
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.show(context, message: 'Failed to archive: $e');
        }
      }
    }
  }
}
