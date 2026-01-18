// lib/ui/machine_management/view/web_admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import '../view_model/machine_viewmodel.dart';
import '../new_widgets/web_stats_row.dart';
import '../new_widgets/web_admin_table_container.dart';
import '../new_widgets/web_admin_view_details_modal.dart';
import '../new_widgets/web_admin_edit_dialog.dart';
import '../new_widgets/web_admin_add_dialog.dart';
import '../models/machine_state.dart';
import '../../core/widgets/web_common_widgets.dart';

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
                  onEdit: (machine) => _showEditDialog(context, machine, notifier),
                  onView: (machine) => _showViewDetailsDialog(context, machine, notifier),
                  onPageChanged: notifier.onPageChanged,
                  onItemsPerPageChanged: notifier.onItemsPerPageChanged,
                  onAddMachine: () => _showAddMachineDialog(context, notifier),
                ),
              ),
            ),
    );
  }

  void _showAddMachineDialog(BuildContext context, MachineViewModel notifier) {
    WebDialogWrapper.show(
      context: context,
      child: WebAdminAddDialog(
        onCreate: ({
          required String machineId,
          required String machineName,
        }) async {
          await notifier.addMachine(
            machineId: machineId,
            machineName: machineName,
            assignedUserIds: [],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, MachineModel machine, MachineViewModel notifier) {
    WebDialogWrapper.show(
      context: context,
      child: WebAdminEditDialog(
        machine: machine,
        onUpdate: ({
          required String machineId,
          required String machineName,
        }) async {
          await notifier.updateMachine(
            machineId: machineId,
            machineName: machineName,
          );
        },
      ),
    );
  }

  void _showViewDetailsDialog(BuildContext context, MachineModel machine, MachineViewModel notifier) {
    WebDialogWrapper.show(
      context: context,
      constraints: const BoxConstraints(maxWidth: 800),
      child: WebAdminViewDetailsModal(
        machine: machine,
        onArchive: () => _handleArchive(context, machine, notifier),
      ),
    );
  }

  Future<void> _handleArchive(BuildContext context, MachineModel machine, MachineViewModel notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
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
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Machine archived successfully',
                style: WebTextStyles.bodyMedium.copyWith(
                  color: WebColors.buttonText,
                ),
              ),
              backgroundColor: WebColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to archive: $e',
                style: WebTextStyles.bodyMedium.copyWith(
                  color: WebColors.buttonText,
                ),
              ),
              backgroundColor: WebColors.error,
            ),
          );
        }
      }
    }
  }
}