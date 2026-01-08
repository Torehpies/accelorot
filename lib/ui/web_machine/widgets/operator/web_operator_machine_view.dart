import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../machine_management/view_model/operator_machine_notifier.dart';
import '../../../../services/sess_service.dart';
import '../../../core/ui/admin_search_bar.dart';
import '../../../core/ui/admin_app_bar.dart';
import 'web_operator_machine_list.dart';

class WebOperatorMachineView extends ConsumerStatefulWidget {
  const WebOperatorMachineView({super.key});

  @override
  ConsumerState<WebOperatorMachineView> createState() => _WebOperatorMachineViewState();
}

class _WebOperatorMachineViewState extends ConsumerState<WebOperatorMachineView> {
  final _searchFocusNode = FocusNode();
  String? _teamId;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  Future<void> _loadTeamIdAndInit() async {
    try {
      final sessionService = SessionService();
      final userData = await sessionService.getCurrentUserData();
      _teamId = userData?['teamId'] as String?;

      if (_teamId != null && mounted) {
        await ref.read(operatorMachineProvider.notifier).initialize(_teamId!);
      }
    } catch (e) {
      debugPrint('Error loading team ID: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AdminAppBar(title: 'My Machines'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Summary Cards Row
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.devices,
                        label: 'Active Machines',
                        count: state.activeMachinesCount,
                        iconBackgroundColor: Colors.green[50]!,
                        iconColor: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.archive,
                        label: 'Archived',
                        count: state.archivedMachinesCount,
                        iconBackgroundColor: Colors.orange[50]!,
                        iconColor: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.folder,
                        label: 'Total Machines',
                        count: state.machines.length,
                        iconBackgroundColor: Colors.teal[50]!,
                        iconColor: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Main Container
              Expanded(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Header with Title and Search
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text(
                              'My Machines',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const Spacer(),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: AdminSearchBar(
                                searchQuery: state.searchQuery,
                                onSearchChanged: notifier.setSearchQuery,
                                onRefresh: _handleRefresh,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(child: _buildContent(state)),
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

  Widget _buildContent(OperatorMachineState state) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_teamId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No team assigned.\nPlease contact support.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(operatorMachineProvider.notifier).clearError();
                if (_teamId != null) {
                  ref.read(operatorMachineProvider.notifier).initialize(_teamId!);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return WebOperatorMachineList(
      machines: state.displayedMachines,
      hasMoreToLoad: state.hasMoreToLoad,
      remainingCount: state.remainingCount,
      onLoadMore: ref.read(operatorMachineProvider.notifier).loadMore,
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required int count,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}