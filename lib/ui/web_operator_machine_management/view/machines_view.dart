import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/machine_management/view_model/operator_machine_notifier.dart';
import '../widgets/stat_card.dart';
import '../widgets/machine_table.dart';
import '../widgets/machine_mobile_card.dart';
import '../widgets/pagination.dart';
import '../../../../../ui/machine_management/widgets/machine_view_dialog.dart';

/// Main machines view connected to real data
class MachinesView extends ConsumerStatefulWidget {
  final String teamId;

  const MachinesView({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<MachinesView> createState() => _MachinesViewState();
}

class _MachinesViewState extends ConsumerState<MachinesView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initialize the notifier with teamId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(operatorMachineProvider.notifier).initialize(widget.teamId);
    });
  }

  void _onSearchChanged() {
    ref.read(operatorMachineProvider.notifier)
        .setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorMachineProvider);

    // Show error if any
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(operatorMachineProvider.notifier).clearError();
              },
            ),
          ),
        );
        ref.read(operatorMachineProvider.notifier).clearError();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktop = screenWidth > 1200;
          final isTablet = screenWidth > 768 && screenWidth <= 1200;
          final isMobile = screenWidth <= 768;

          if (state.isLoading && state.machines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Stats Cards
              _buildStatsSection(state, isDesktop, isTablet, isMobile),

              // Machine List Card
              Expanded(
                child: _buildMachineListCard(
                  state,
                  isDesktop,
                  isTablet,
                  isMobile,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: _buildStatsCards(state, isDesktop, isTablet, isMobile),
    );
  }

  Widget _buildStatsCards(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final stats = [
      StatCardData(
        label: 'Active Machines',
        count: state.activeMachinesCount.toString(),
        change: '+0',
        subtext: 'currently active',
        color: const Color(0xFF10B981),
        lightColor: const Color(0xFFD1FAE5),
        icon: Icons.check_circle_outline,
      ),
      StatCardData(
        label: 'Archived Machines',
        count: state.archivedMachinesCount.toString(),
        change: '+0',
        subtext: 'archived machines',
        color: const Color(0xFFF59E0B),
        lightColor: const Color(0xFFFEF3C7),
        icon: Icons.archive_outlined,
      ),
      StatCardData(
        label: 'Total Machines',
        count: state.machines.length.toString().padLeft(2, '0'),
        change: '+0',
        subtext: 'all machines',
        color: const Color(0xFF3B82F6),
        lightColor: const Color(0xFFDBEAFE),
        icon: Icons.precision_manufacturing_outlined,
      ),
      StatCardData(
        label: 'Filtered Results',
        count: state.filteredMachines.length.toString().padLeft(2, '0'),
        change: '+0',
        subtext: 'matching search',
        color: const Color(0xFF8B5CF6),
        lightColor: const Color(0xFFEDE9FE),
        icon: Icons.filter_alt_outlined,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: stats
            .map((stat) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: StatCardWidget(data: stat),
                  ),
                ))
            .toList(),
      );
    } else if (isTablet) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: stats
            .map((stat) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 80) / 2,
                  child: StatCardWidget(data: stat),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: stats
            .map((stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: StatCardWidget(data: stat),
                ))
            .toList(),
      );
    }
  }

  Widget _buildMachineListCard(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32.0 : 16.0,
        0,
        isDesktop ? 32.0 : 16.0,
        isDesktop ? 32.0 : 16.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildListHeader(isDesktop, isMobile),
            Expanded(
              child: state.displayedMachines.isEmpty
                  ? _buildEmptyState()
                  : (isMobile
                      ? MachineMobileCardWidget(
                          machines: state.displayedMachines,
                          onMachineAction: _handleMachineAction,
                        )
                      : MachineTableWidget(
                          machines: state.displayedMachines,
                          onMachineAction: _handleMachineAction,
                        )),
            ),
            
            // Pagination - Always show if there are any machines
            if (state.filteredMachines.isNotEmpty)
              PaginationWidget(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                isDesktop: isDesktop,
                canGoNext: state.currentPage < state.totalPages,
                canGoPrevious: state.currentPage > 1,
                onNext: () => ref
                    .read(operatorMachineProvider.notifier)
                    .goToNextPage(),
                onPrevious: () => ref
                    .read(operatorMachineProvider.notifier)
                    .goToPreviousPage(),
                onPageChanged: (page) => ref
                    .read(operatorMachineProvider.notifier)
                    .goToPage(page),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(bool isDesktop, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Machine List',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              if (isDesktop)
                Row(
                  children: [
                    _buildRefreshButton(),
                    const SizedBox(width: 12),
                    _buildSearchField(),
                  ],
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 8),
                _buildRefreshButton(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    final state = ref.watch(operatorMachineProvider);
    return InkWell(
      onTap: state.isLoading
          ? null
          : () {
              ref
                  .read(operatorMachineProvider.notifier)
                  .refresh(widget.teamId);
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.refresh,
                size: 20,
                color: Color(0xFF6B7280),
              ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 280,
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(operatorMachineProvider.notifier)
                        .clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final state = ref.watch(operatorMachineProvider);
    final hasSearch = state.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.precision_manufacturing_outlined,
              size: 64,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No machines found' : 'No machines yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try adjusting your search query'
                  : 'Add your first machine to get started',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearch) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(operatorMachineProvider.notifier).clearSearch();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMachineAction(String machineId) {
    final state = ref.read(operatorMachineProvider);
    final machine = state.machines.firstWhere(
      (m) => m.machineId == machineId,
      orElse: () => throw Exception('Machine not found'),
    );

    showDialog(
      context: context,
      builder: (context) => MachineViewDialog(
        machine: machine,
      ),
    );
  }
}