// lib/ui/machine_management/view/mobile_admin_machine_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/search_bar_widget.dart';
import 'package:flutter_application_1/ui/core/widgets/mobile_date_filter_button.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../view_model/admin_machine_notifier.dart';
import '../../../services/sess_service.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/data_card.dart';
import '../widgets/machine_tab_filter.dart';

class AdminMachineView extends ConsumerStatefulWidget {
  const AdminMachineView({super.key});

  @override
  ConsumerState<AdminMachineView> createState() => _AdminMachineViewState();
}

class _AdminMachineViewState extends ConsumerState<AdminMachineView> {
  String? _teamId;
  bool _isAdmin = false;
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
    _isAdmin = userData?['role'] == 'admin';

    if (_teamId != null) {
      ref.read(adminMachineProvider.notifier).initialize(_teamId!);
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

  void _onDateFilterChanged(DateFilterRange range) {
    // TODO: Implement date filtering in your notifier
    // For now, just show what was selected
    if (range.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filter: ${_getFilterDisplayText(range)}'),
          duration: const Duration(seconds: 2),
        ),
      );
      // When implemented:
      // ref.read(adminMachineProvider.notifier).filterByDateRange(
      //   range.startDate!,
      //   range.endDate!,
      // );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Date filter cleared')));
      // When implemented:
      // ref.read(adminMachineProvider.notifier).clearDateFilter();
    }
  }

  String _getFilterDisplayText(DateFilterRange range) {
    switch (range.type) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last30Days:
        return 'Last 30 Days';
      case DateFilterType.custom:
        return 'Custom: ${DateFormat('MMM d, y').format(range.customDate!)}';
      case DateFilterType.none:
        return 'None';
    }
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
      return const Color(0xFF757575);
    }

    switch (machine.status) {
      case MachineStatus.active:
        return AppColors.green100;
      case MachineStatus.inactive:
        return const Color(0xFFFFA726);
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
    final state = ref.watch(adminMachineProvider);
    final notifier = ref.read(adminMachineProvider.notifier);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Custom header with search bar on left and filter/add on right
            Container(
              color: AppColors.background2,
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

                  // Search bar + Filter/Add buttons row
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

                      // Date filter button
                      MobileDateFilterButton(
                        onFilterChanged: _onDateFilterChanged,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Filters
                    MachineTabFilter(
                      selectedTab: state.selectedTab,
                      onTabSelected: notifier.setFilterTab,
                    ),
                    const SizedBox(height: 24),

                    // Machine List
                    Expanded(child: _buildMachineContent(state, notifier)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineContent(
    AdminMachineState state,
    AdminMachineNotifier notifier,
  ) {
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

    if (state.filteredMachinesByTab.isEmpty) {
      String emptyMessage;
      switch (state.selectedTab) {
        case MachineFilterTab.archived:
          emptyMessage = 'No archived machines';
          break;
        case MachineFilterTab.active:
          emptyMessage = 'No active machines';
          break;
        case MachineFilterTab.suspended:
          emptyMessage = 'No inactive machines';
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
                state.searchQuery.isNotEmpty
                    ? 'No machines found'
                    : emptyMessage,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
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
          onAction: (action, machineData) {
            if (action == 'view') {
              _navigateToDetails(machineData);
            }
          },
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
