// lib/ui/machine_management/view/web_operator_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_colors.dart';
import '../view_model/machine_viewmodel.dart';
import '../new_widgets/web_stats_row.dart';
import '../new_widgets/web_operator_table_container.dart';
import '../dialogs/web_operator_view_details_dialog.dart';
import '../models/machine_state.dart';
import '../../core/widgets/web_base_container.dart';

class WebOperatorMachineScreen extends ConsumerWidget {
  const WebOperatorMachineScreen({super.key});

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
                table: WebOperatorTableContainer(
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
                  onView: (machine) => _showViewDetailsDialog(context, machine),
                  onPageChanged: notifier.onPageChanged,
                  onItemsPerPageChanged: notifier.onItemsPerPageChanged,
                ),
              ),
            ),
    );
  }

  void _showViewDetailsDialog(BuildContext context, MachineModel machine) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => WebOperatorViewDetailsDialog(machine: machine),
    );
  }
}
