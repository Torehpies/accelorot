
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_machine_notifier.dart';
import '../../../services/sess_service.dart';
import '../widgets/admin_machine_card.dart';
import '../widgets/machine_tab_filter.dart';

class AdminMachineView extends ConsumerStatefulWidget {
  const AdminMachineView({super.key});

  @override
  ConsumerState<AdminMachineView> createState() => _AdminMachineViewState();
}

class _AdminMachineViewState extends ConsumerState<AdminMachineView> {
  String? _teamId;
  bool _isAdmin = false; // Track admin role

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  Future<void> _loadTeamIdAndInit() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    _teamId = userData?['teamId'] as String?;
    _isAdmin = userData?['role'] == 'admin'; // Adjust key if your role field differs

    if (_teamId != null) {
      ref.read(adminMachineProvider.notifier).initialize(_teamId!);
    }

    if (mounted) setState(() {}); // Rebuild to show/hide Add button
  }

  void _onAddPressed() {
    // TODO: Navigate to "Add Machine" screen
    // Example:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => AddMachineScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add machine functionality not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMachineProvider);
    final notifier = ref.read(adminMachineProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Unfocus any TextField
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: MobileHeader(
          title: 'Machine List',
          showSearch: true,
          showFilterButton: true,
          showAddButton: _isAdmin,
          searchQuery: state.searchQuery,
          onSearchChanged: notifier.setSearchQuery,
          onDateRangeChanged: (range) {
            // Optional: Handle date filtering later
            // notifier.setDateFilter(range);
          },
          onAddPressed: _onAddPressed,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    );
  }

  Widget _buildMachineContent(
    AdminMachineState state,
    AdminMachineNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  notifier.clearError();
                  if (_teamId != null) notifier.initialize(_teamId!);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty ? 'No machines found' : emptyMessage,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          );
        }

        final machine = state.displayedMachines[index];
        return AdminMachineCard(machine: machine);
      },
    );
  }
}