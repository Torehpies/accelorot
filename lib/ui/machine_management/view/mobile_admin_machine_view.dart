// lib/ui/machine_management/view/mobile_admin_machine_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/mobile_search_bar.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/mobile_date_filter_button.dart';
import 'package:flutter_application_1/ui/core/widgets/filters/mobile_status_filter_button.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../view_model/mobile_machine_viewmodel.dart';
import '../models/mobile_machine_state.dart';
import '../../../services/sess_service.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/data_card.dart';

class AdminMachineView extends ConsumerStatefulWidget {
  const AdminMachineView({super.key});

  @override
  ConsumerState<AdminMachineView> createState() => _AdminMachineViewState();
}

class _AdminMachineViewState extends ConsumerState<AdminMachineView>
    with SingleTickerProviderStateMixin {
  String? _teamId;
  bool _isAdmin = false;
  final FocusNode _searchFocusNode = FocusNode();

  // Animation for skeleton loading
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamIdAndInit() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    _teamId = userData?['teamId'] as String?;
    _isAdmin = userData?['role'] == 'admin';

    if (_teamId != null) {
      ref.read(mobileMachineViewModelProvider.notifier).initialize(_teamId!);
    }

    if (mounted) setState(() {});
  }

  void _onAddPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add machine functionality not implemented yet.'),
      ),
    );
  }

  void _navigateToDetails(MachineModel machine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MachineDetailsView(machine: machine, teamId: machine.teamId),
      ),
    );
  }

  Color _getIconColorForStatus(MachineModel machine) {
    if (machine.isArchived) {
      return AppColors.textSecondary;
    }

    switch (machine.status) {
      case MachineStatus.active:
        return AppColors.green100;
      case MachineStatus.inactive:
        return AppColors.yellowForeground;
      case MachineStatus.underMaintenance:
        return AppColors.error;
    }
  }

  Color _getStatusBgColor(MachineModel machine) {
    if (machine.isArchived) {
      return AppColors.redBackground;
    }

    switch (machine.status) {
      case MachineStatus.active:
        return AppColors.greenBackground;
      case MachineStatus.inactive:
        return AppColors.yellowBackground;
      case MachineStatus.underMaintenance:
        return AppColors.redBackground;
    }
  }

  String _getStatusLabel(MachineModel machine) {
    if (machine.isArchived) {
      return 'Archived';
    }

    switch (machine.status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Inactive';
      case MachineStatus.underMaintenance:
        return 'Under Maintenance';
    }
  }

  String _getDescription(MachineModel machine) {
    return 'ID: ${machine.machineId}';
  }

  String _getDateCreated(MachineModel machine) {
    return DateFormat('MMM dd, yyyy').format(machine.dateCreated);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileMachineViewModelProvider);
    final notifier = ref.read(mobileMachineViewModelProvider.notifier);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Custom header with filters
            Container(
              color: AppColors.background,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text('Machine List', style: AppTextStyles.heading1),
                  const SizedBox(height: 12),

                  // Filter row: Search + Status + Date + Add
                  Row(
                    children: [
                      // Search bar - takes remaining space
                      Expanded(
                        child: SearchBarWidget(
                          onSearchChanged: notifier.setSearchQuery,
                          onClear: () => notifier.setSearchQuery(''),
                          focusNode: _searchFocusNode,
                          hintText: 'Search machines...',
                          height: 40,
                          borderRadius: 12,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status filter button
                      MobileStatusFilterButton(
                        currentFilter: state.selectedStatusFilter,
                        onFilterChanged: notifier.setStatusFilter,
                        isLoading: state.isLoading,
                      ),
                      const SizedBox(width: 8),

                      // Date filter button
                      MobileDateFilterButton(
                        onFilterChanged: notifier.setDateFilter,
                        isLoading: state.isLoading,
                      ),

                      // Add button (only for admin)
                      if (_isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _onAddPressed,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: _buildMachineContent(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineContent(
    MobileMachineState state,
    MobileMachineViewModel notifier,
  ) {
    // Show skeleton on initial load
    if (state.isLoading && state.machines.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 3,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    }

    // Show spinner on refresh (when data already exists)
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.green100),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  notifier.clearError();
                  if (_teamId != null) notifier.initialize(_teamId!);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('Retry', style: AppTextStyles.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.filteredMachines.isEmpty) {
      String emptyMessage;
      switch (state.selectedStatusFilter) {
        case MachineStatusFilter.inactive:
          emptyMessage = 'No archived machines';
          break;
        case MachineStatusFilter.active:
          emptyMessage = 'No active machines';
          break;
        case MachineStatusFilter.underMaintenance:
          emptyMessage = 'No suspended machines';
          break;
        default:
          emptyMessage = 'No machines available';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                state.hasActiveFilters
                    ? 'No machines match your filters'
                    : emptyMessage,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Clear filters button
              if (state.hasActiveFilters) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: notifier.clearAllFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green100,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_teamId != null) {
          await notifier.refresh(_teamId!);
        }
      },
      color: AppColors.green100,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: state.displayedMachines.length + (state.hasMoreToLoad ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.displayedMachines.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: ElevatedButton.icon(
                onPressed: notifier.loadMore,
                icon: const Icon(Icons.expand_more),
                label: Text(
                  'Load More (${state.remainingCount} remaining)',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            );
          }

          final machine = state.displayedMachines[index];

          return DataCard<MachineModel>(
            data: machine,
            icon: Icons.precision_manufacturing,
            iconBgColor: _getIconColorForStatus(machine),
            title: machine.machineName,
            description: _getDescription(machine),
            category: _getStatusLabel(machine),
            status: 'Created on ${_getDateCreated(machine)}',
            userName: 'All Team Members',
            statusColor: _getStatusBgColor(machine),
            onTap: () => _navigateToDetails(machine),
          );
        },
      ),
    );
  }

  /// Build skeleton loading card with pulsing animation
  Widget _buildSkeletonCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.backgroundBorder,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    AppColors.grey,
                    AppColors.background,
                    _pulseAnimation.value,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),

              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.grey,
                          AppColors.background,
                          _pulseAnimation.value,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.grey,
                          AppColors.background,
                          _pulseAnimation.value,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),

                    // Status badge
                    Row(
                      children: [
                        Container(
                          height: 24,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              AppColors.grey,
                              AppColors.background,
                              _pulseAnimation.value,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MachineDetailsView extends StatelessWidget {
  final MachineModel machine;
  final String teamId;

  const MachineDetailsView({
    super.key,
    required this.machine,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(machine.machineName)),
      body: Center(child: Text('Machine Details for ${machine.machineName}')),
    );
  }
}