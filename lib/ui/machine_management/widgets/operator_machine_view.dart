import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/operator_machine_notifier.dart';
import '../../../services/sess_service.dart';
import 'operator_machine_card.dart';
import 'search_bar_widget.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() =>
      _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
  final _searchController = TextEditingController();
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
    _searchController.dispose();
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
            'Machine Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        body: _buildBody(state, notifier),
      ),
    );
  }

  Widget _buildBody(
    OperatorMachineState state,
    OperatorMachineNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              onSearchChanged: (query) {
                notifier.setSearchQuery(query);
              },
              onClear: () {
                _searchController.clear();
                notifier.clearSearch();
              },
              focusNode: _searchFocusNode,
            ),
            const SizedBox(height: 16),

            // Machine Count Stats (Simple style like old version)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.precision_manufacturing,
                    label: 'Active Machines',
                    value: '${state.activeMachinesCount}',
                    color: Colors.teal,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  _buildStatItem(
                    icon: Icons.archive_outlined,
                    label: 'Archived',
                    value: '${state.archivedMachinesCount}',
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Machine List
            Expanded(
              child: state.displayedMachines.isEmpty
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
                                icon: const Icon(Icons.expand_more),
                                label: Text(
                                  'Load More (${state.remainingCount} remaining)',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return OperatorMachineCard(
                          machine: state.displayedMachines[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
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
            state.searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.precision_manufacturing_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No machines found'
                : 'No machines available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}