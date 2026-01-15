// lib/ui/machine_management/view/web_operator_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import '../view_model/machine_viewmodel.dart';
import '../new_widgets/web_stats_row.dart';
import '../new_widgets/web_operator_table_container.dart';
import '../new_widgets/web_operator_view_details_modal.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../models/machine_state.dart';

class OperatorMachineScreen extends ConsumerStatefulWidget {
  final String teamId;

  const OperatorMachineScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<OperatorMachineScreen> createState() => _OperatorMachineScreenState();
}

class _OperatorMachineScreenState extends ConsumerState<OperatorMachineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(machineViewModelProvider.notifier).initialize(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(machineViewModelProvider);
    final notifier = ref.read(machineViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.errorMessage != null && !state.isLoading
            ? _buildErrorState(state.errorMessage!)
            : _buildContent(context, state, notifier),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MachineState state,
    MachineViewModel notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebColors.primaryBorder, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              
              // Stats Cards Row (same as admin)
              const MachineStatsRow(),

              const SizedBox(height: 12),

              // Machine Table Container (operator version - no add/edit)
              Expanded(
                child: WebOperatorTableContainer(
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
                  onView: (machine) => _showViewDetailsDialog(machine),
                  onPageChanged: notifier.onPageChanged,
                  onItemsPerPageChanged: notifier.onItemsPerPageChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: WebColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: WebColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: WebTextStyles.bodyMediumGray.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(machineViewModelProvider.notifier).initialize(widget.teamId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.tealAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showViewDetailsDialog(MachineModel machine) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: WebOperatorViewDetailsModal(
              machine: machine,
            ),
          ),
        );
      },
    );
  }
}