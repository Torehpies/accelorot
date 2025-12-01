import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_machine_notifier.dart';
import '../../../services/sess_service.dart';
import '../../../frontend/operator/machine_management/widgets/search_bar_widget.dart';
import '../../../frontend/operator/machine_management/components/machine_action_card.dart';
import 'add_machine_modal.dart';
import 'admin_machine_card.dart';

class AdminMachineView extends ConsumerStatefulWidget {
  const AdminMachineView({super.key});

  @override
  ConsumerState<AdminMachineView> createState() => _AdminMachineViewState();
}

class _AdminMachineViewState extends ConsumerState<AdminMachineView> {
  final _searchFocusNode = FocusNode();
  String? _teamId;

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  Future<void> _loadTeamIdAndInit() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();
    _teamId = userData?['teamId'] as String?;

    if (_teamId != null) {
      ref.read(adminMachineProvider.notifier).initialize(_teamId!);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _showAddMachineModal() {
    if (_teamId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddMachineModal(teamId: _teamId!),
    );
  }

  Future<void> _handleRefresh() async {
    if (_teamId != null) {
      await ref.read(adminMachineProvider.notifier).refresh(_teamId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMachineProvider);
    final notifier = ref.read(adminMachineProvider.notifier);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leading: state.showArchived
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {

                    _searchFocusNode.unfocus();
                    notifier.clearSearch();
                    notifier.setShowArchived(false);
                  },
                )
              : null,
          automaticallyImplyLeading: false,
          title: Text(
            state.showArchived ? 'Archived Machines' : 'Machine Management',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _handleRefresh,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Cards Row - Only show when not in archived view
              if (!state.showArchived)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MachineActionCard(
                            icon: Icons.archive,
                            label: 'Archive',
                            onPressed: () {

                              _searchFocusNode.unfocus();
                              notifier.clearSearch();
                              notifier.setShowArchived(true);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MachineActionCard(
                            icon: Icons.report,
                            label: 'Reports',
                            onPressed: () {
                              // Navigate to reports (implement later)
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MachineActionCard(
                            icon: Icons.add_circle_outline,
                            label: 'Add Machine',
                            onPressed: _showAddMachineModal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Main Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SearchBarWidget(
                          onSearchChanged: notifier.setSearchQuery,
                          onClear: () {

                            notifier.clearSearch();
                          },
                          focusNode: _searchFocusNode,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              state.showArchived
                                  ? 'Archived Machines'
                                  : 'List of Machines',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildMachineContent(state, notifier)),
                    ],
                  ),
                ),
              ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.showArchived ? Icons.archive : Icons.inbox_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No machines found'
                    : state.showArchived
                        ? 'No archived machines'
                        : 'No machines available. Add one to get started!',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.displayedMachines.length + (state.hasMoreToLoad ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.displayedMachines.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              onPressed: notifier.loadMore,
              icon: const Icon(Icons.expand_more),
              label: Text(
                'Load More (${state.remainingCount} remaining)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }

        final machine = state.displayedMachines[index];
        return AdminMachineCard(machine: machine, teamId: _teamId!);
      },
    );
  }
}