// lib/ui/machine_management/view/web_admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import '../view_model/admin_machine_notifier.dart';
import '../new_widgets/web_stats_row.dart';
import '../new_widgets/web_table_container.dart';
import '../new_widgets/web_view_details_modal.dart';
import '../new_widgets/web_edit_dialog.dart';
import '../new_widgets/web_add_dialog.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class AdminMachineScreen extends ConsumerStatefulWidget {
  final String teamId;

  const AdminMachineScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<AdminMachineScreen> createState() => _AdminMachineScreenState();
}

class _AdminMachineScreenState extends ConsumerState<AdminMachineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminMachineProvider.notifier).initialize(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMachineProvider);
    final notifier = ref.read(adminMachineProvider.notifier);

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
    AdminMachineState state,
    AdminMachineNotifier notifier,
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
              MachineStatsRow(
                machines: state.machines,
                isLoading: state.isLoading,
              ),

              const SizedBox(height: 12),

              // Machine Table Container
              Expanded(
                child: MachineTableContainer(
                  machines: state.paginatedMachines,
                  isLoading: state.isLoading,
                  selectedStatusFilter: state.selectedStatusFilter,
                  searchQuery: state.searchQuery,
                  sortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  itemsPerPage: state.itemsPerPage,
                  totalItems: state.filteredMachinesByStatus.length,
                  onStatusFilterChanged: notifier.setStatusFilter,
                  onDateFilterChanged: (dateFilter) {
                    // TODO: Implement date filter if needed
                  },
                  onSearchChanged: notifier.setSearchQuery,
                  onSort: notifier.onSort,
                  onEdit: (machine) => _showEditDialog(machine, notifier),
                  onView: (machine) => _showViewDetailsDialog(machine, notifier),
                  onPageChanged: notifier.onPageChanged,
                  onItemsPerPageChanged: notifier.onItemsPerPageChanged,
                  onAddMachine: () => _showAddMachineDialog(notifier),
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
              ref.read(adminMachineProvider.notifier).initialize(widget.teamId);
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

  void _showAddMachineDialog(AdminMachineNotifier notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: MachineAddDialog(
            onCreate: ({
              required String machineId,
              required String machineName,
            }) async {
              await notifier.addMachine(
                teamId: widget.teamId,
                machineId: machineId,
                machineName: machineName,
                assignedUserIds: [], // All team members
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(MachineModel machine, AdminMachineNotifier notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: MachineEditDialog(
            machine: machine,
            onUpdate: ({
              required String machineId,
              required String machineName,
            }) async {
              await notifier.updateMachine(
                teamId: widget.teamId,
                machineId: machineId,
                machineName: machineName,
              );
            },
          ),
        );
      },
    );
  }

  void _showViewDetailsDialog(MachineModel machine, AdminMachineNotifier notifier) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: MachineViewDetailsModal(
              machine: machine,
              onArchive: () => _handleArchive(machine, notifier),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleArchive(MachineModel machine, AdminMachineNotifier notifier) async {
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
        await notifier.archiveMachine(widget.teamId, machine.machineId);
        if (mounted) {
          Navigator.of(context).pop(); // Close the details modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Machine archived successfully'),
              backgroundColor: WebColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
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