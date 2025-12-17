import 'package:flutter/material.dart';
import '../models/machines_view_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/machine_table.dart';
import '../widgets/machine_mobile_card.dart';
import '../widgets/pagination.dart';

/// Main machines view - the screen itself
class MachinesView extends StatefulWidget {
  const MachinesView({super.key});

  @override
  State<MachinesView> createState() => _MachinesViewState();
}

class _MachinesViewState extends State<MachinesView> {
  late final MachinesViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = MachinesViewModel();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _viewModel.searchMachines(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktop = screenWidth > 1200;
          final isTablet = screenWidth > 768 && screenWidth <= 1200;
          final isMobile = screenWidth <= 768;

          return AnimatedBuilder(
            animation: _viewModel,
            builder: (context, child) {
              return Column(
                children: [
                  // Stats Cards
                  _buildStatsSection(isDesktop, isTablet, isMobile),

                  // Machine List Card
                  Expanded(
                    child: _buildMachineListCard(
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(bool isDesktop, bool isTablet, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: _buildStatsCards(isDesktop, isTablet, isMobile),
    );
  }

  Widget _buildStatsCards(bool isDesktop, bool isTablet, bool isMobile) {
    final stats = [
      StatCardData(
        label: 'Active Machines',
        count: _viewModel.activeMachines.toString(),
        change: _viewModel.activeChange,
        subtext: 'activated machines this month',
        color: const Color(0xFF10B981),
        lightColor: const Color(0xFFD1FAE5),
        icon: Icons.check_circle_outline,
      ),
      StatCardData(
        label: 'Inactive Machines',
        count: _viewModel.inactiveMachines.toString(),
        change: _viewModel.inactiveChange,
        subtext: 'disabled machines this month',
        color: const Color(0xFFF59E0B),
        lightColor: const Color(0xFFFEF3C7),
        icon: Icons.cancel_outlined,
      ),
      StatCardData(
        label: 'Suspended Machines',
        count: _viewModel.suspendedMachines.toString().padLeft(2, '0'),
        change: _viewModel.suspendedChange,
        subtext: 'suspended machines this month',
        color: const Color(0xFFEF4444),
        lightColor: const Color(0xFFFEE2E2),
        icon: Icons.pause_circle_outline,
      ),
      StatCardData(
        label: 'New Machines',
        count: _viewModel.newMachines.toString().padLeft(2, '0'),
        change: _viewModel.newChange,
        subtext: 'new machines this month',
        color: const Color(0xFF3B82F6),
        lightColor: const Color(0xFFDBEAFE),
        icon: Icons.add_circle_outline,
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

  Widget _buildMachineListCard(bool isDesktop, bool isTablet, bool isMobile) {
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
              child: isMobile
                  ? MachineMobileCardWidget(
                      machines: _viewModel.getMachinesForCurrentPage(),
                    )
                  : MachineTableWidget(
                      machines: _viewModel.getMachinesForCurrentPage(),
                      onMachineAction: (machineId) {
                        // Handle machine action
                        print('Action on machine: $machineId');
                      },
                    ),
            ),
            PaginationWidget(
              currentPage: _viewModel.currentPage,
              totalPages: _viewModel.totalPages,
              onPageChanged: _viewModel.goToPage,
              onNext: _viewModel.nextPage,
              onPrevious: _viewModel.previousPage,
              canGoNext: _viewModel.canGoNext,
              canGoPrevious: _viewModel.canGoPrevious,
              isDesktop: isDesktop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(bool isDesktop, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
                    _buildHeaderButton(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                    _buildSearchField(),
                  ],
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            _buildSearchField(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return InkWell(
      onTap: () {
        // Handle calendar action
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
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
        decoration: const InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}