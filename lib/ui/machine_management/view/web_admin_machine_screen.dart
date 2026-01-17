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
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../models/machine_state.dart';

class AdminMachineScreen extends ConsumerWidget {
  const AdminMachineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(machineViewModelProvider);
    final notifier = ref.read(machineViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.errorMessage != null && !state.isLoading
            ? _buildErrorState(context, ref, state.errorMessage!)
            : _buildContent(context, ref, state, notifier),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
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
              // Stats Cards Row
              const MachineStatsRow(),

              const SizedBox(height: 12),

              // Machine Table Container
              Expanded(
                child: WebAdminTableContainer(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String message) {
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
              ref.invalidate(machineViewModelProvider);
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

  void _showAddMachineDialog(BuildContext context, MachineViewModel notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
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
      },
    );
  }

  void _showEditDialog(BuildContext context, MachineModel machine, MachineViewModel notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
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
      },
    );
  }

  void _showViewDetailsDialog(BuildContext context, MachineModel machine, MachineViewModel notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: WebAdminViewDetailsModal(
              machine: machine,
              onArchive: () => _handleArchive(context, machine, notifier),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleArchive(BuildContext context, MachineModel machine, MachineViewModel notifier) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Archive Machine',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          'Are you sure you want to archive "${machine.machineName}"?',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.error,
              foregroundColor: Colors.white,
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
            const SnackBar(
              content: Text('Machine archived successfully'),
              backgroundColor: WebColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to archive: $e'),
              backgroundColor: WebColors.error,
            ),
          );
        }
      }
    }
  }
}