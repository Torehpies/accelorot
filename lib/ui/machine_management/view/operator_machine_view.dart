import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/operator_machine_notifier.dart';
import '../../../services/sess_service.dart';
import '../widgets/operator_machine_card.dart';
import '../widgets/search_bar_widget.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() =>
      _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
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
      ref.read(operatorMachineProvider.notifier).initialize(_teamId!);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_teamId != null) {
      await ref.read(operatorMachineProvider.notifier).refresh(_teamId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorMachineProvider);
    final notifier = ref.read(operatorMachineProvider.notifier);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'My Machines',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machines Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Active: ${state.activeMachinesCount} | Disabled: ${state.archivedMachinesCount}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SearchBarWidget(
                          onSearchChanged: notifier.setSearchQuery,
                          onClear: notifier.clearSearch,
                          focusNode: _searchFocusNode,
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text(
                              'Your Machines',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${state.filteredMachines.length} machine(s)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Machine List with Error/Loading States Inside
                      Expanded(child: _buildContent(state, notifier)),
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

  Widget _buildContent(
    OperatorMachineState state,
    OperatorMachineNotifier notifier,
  ) {
    // Loading State - inside container
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State - inside container
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

    // Empty State
    if (state.filteredMachines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No machines found matching "${state.searchQuery}"'
                  : 'No machines available in your team.\nContact your admin for machine assignment.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Content - Machine List
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.displayedMachines.length + (state.hasMoreToLoad ? 1 : 0),
      itemBuilder: (context, index) {
        // Show "Load More" button at the end
        if (index == state.displayedMachines.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: notifier.loadMore,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  'Load More (${state.remainingCount} remaining)',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          );
        }

        final machine = state.displayedMachines[index];
        return OperatorMachineCard(machine: machine);
      },
    );
  }
}