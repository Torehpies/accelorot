import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';
import '../../../../services/sess_service.dart';
import '../../../core/ui/admin_search_bar.dart';
import '../../../core/ui/admin_app_bar.dart';
import 'web_admin_machine_list.dart';
import 'web_add_machine_modal.dart';

class WebAdminMachineView extends ConsumerStatefulWidget {
  const WebAdminMachineView({super.key});

  @override
  ConsumerState<WebAdminMachineView> createState() => _WebAdminMachineViewState();
}

class _WebAdminMachineViewState extends ConsumerState<WebAdminMachineView> {
  final _searchFocusNode = FocusNode();
  String? _teamId;
  bool _isInitializing = true; //  loading state

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
        await ref.read(adminMachineProvider.notifier).initialize(_teamId!);
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

  void _showAddMachineModal() {
    if (_teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team ID not available. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: WebAddMachineModal(teamId: _teamId!),
        ),
      ),
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AdminAppBar(title: 'Machine Management'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Action Cards Row
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.archive,
                        label: 'Archive',
                        count: null,
                        onPressed: () => notifier.setShowArchived(true),
                        iconBackgroundColor: Colors.orange[50]!,
                        iconColor: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.add_circle_outline,
                        label: 'Add Machine',
                        count: null,
                        onPressed: _showAddMachineModal,
                        iconBackgroundColor: Colors.blue[50]!,
                        iconColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.devices,
                        label: 'Total Machines',
                        count: state.filteredMachines.length,
                        onPressed: () => notifier.setShowArchived(false),
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
                            Text(
                              state.showArchived ? 'Archived Machines' : 'Active Machines',
                              style: const TextStyle(
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

  Widget _buildContent(AdminMachineState state) {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Loading machine data...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
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
                ref.read(adminMachineProvider.notifier).clearError();
                if (_teamId != null) {
                  ref.read(adminMachineProvider.notifier).initialize(_teamId!);
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

    // ✅ Pass non-null teamId
    return WebAdminMachineList(
      machines: state.displayedMachines,
      hasMoreToLoad: state.hasMoreToLoad,
      remainingCount: state.remainingCount,
      onLoadMore: ref.read(adminMachineProvider.notifier).loadMore,
      teamId: _teamId!, 
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required int? count,
    required VoidCallback onPressed,
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
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
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
                    if (count != null) ...[
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}