import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/operator_machine_notifier.dart';
import '../../../services/sess_service.dart';
import 'operator_machine_card.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() =>
      _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
  final _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorMachineProvider);
    final notifier = ref.read(operatorMachineProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Machines',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (_teamId != null) notifier.refresh(_teamId!);
            },
          ),
        ],
      ),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildBody(
    OperatorMachineState state,
    OperatorMachineNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(state.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_teamId != null) {
                  notifier.clearError();
                  notifier.initialize(_teamId!);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Active',
                  value: '${state.activeMachinesCount}',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3), // ✅ FIXED
                ),
                _buildStatItem(
                  icon: Icons.archive,
                  label: 'Archived',
                  value: '${state.archivedMachinesCount}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search machines...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        notifier.clearSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Machine List
          Expanded(
            child: state.filteredMachines.isEmpty
                ? _buildEmptyState(state)
                : ListView.builder(
                    itemCount: state.displayedMachines.length +
                        (state.hasMoreToLoad ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.displayedMachines.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: notifier.loadMore,
                              icon: const Icon(Icons.add_circle_outline),
                              label: Text(
                                'Load More (${state.remainingCount} remaining)',
                              ),
                            ),
                          ),
                        );
                      }

                      final machine = state.displayedMachines[index];
                      return OperatorMachineCard(machine: machine);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9), // ✅ FIXED
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(OperatorMachineState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No machines found'
                : 'No machines assigned yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Contact your administrator to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}