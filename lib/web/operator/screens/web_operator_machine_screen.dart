// lib/frontend/operator/web/web_operator_machine_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/machine_management/operator_machine/controllers/operator_machine_controller.dart';
import '../../../frontend/operator/machine_management/widgets/search_bar_widget.dart';
import '../../operator/widgets/summary_card_widget.dart';
import '../../operator/widgets/machine_card_widget.dart';
import '../../operator/widgets/machine_list_tile_widget.dart';

class WebOperatorMachineScreen extends StatefulWidget {
  final String? viewingOperatorId;

  const WebOperatorMachineScreen({super.key, this.viewingOperatorId});

  @override
  State<WebOperatorMachineScreen> createState() =>
      _WebOperatorMachineScreenState();
}

class _WebOperatorMachineScreenState extends State<WebOperatorMachineScreen> {
  late final OperatorMachineController _controller;
  final FocusNode _searchFocusNode = FocusNode();
  String _viewMode = 'grid'; // 'grid' or 'list'

  @override
  void initState() {
    super.initState();
    _controller =
        OperatorMachineController(viewingOperatorId: widget.viewingOperatorId);
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _controller.refresh();
  }

  void _handleMachineTap(String machineName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $machineName details')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Machine',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_viewMode == 'grid' ? Icons.list : Icons.grid_view),
            tooltip: _viewMode == 'grid' ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isWideScreen ? 32 : 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCards(isWideScreen),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.grey[300]!, width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Your Machines',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.teal.shade200),
                                          ),
                                          child: Text(
                                            '${_controller.filteredMachines.length} machine(s)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.teal.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SearchBarWidget(
                                      onSearchChanged:
                                          _controller.setSearchQuery,
                                      onClear: _controller.clearSearch,
                                      focusNode: _searchFocusNode,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: _buildContent(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(bool isWideScreen) {
    return isWideScreen
        ? Row(
            children: [
              Expanded(
                child: SummaryCardWidget(
                  title: 'Active Machines',
                  value: _controller.activeMachinesCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCardWidget(
                  title: 'Disabled Machines',
                  value: _controller.archivedMachinesCount.toString(),
                  icon: Icons.cancel,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCardWidget(
                  title: 'Total Machines',
                  value: (_controller.activeMachinesCount +
                          _controller.archivedMachinesCount)
                      .toString(),
                  icon: Icons.devices,
                  color: Colors.blue,
                ),
              ),
            ],
          )
        : Column(
            children: [
              SummaryCardWidget(
                title: 'Active Machines',
                value: _controller.activeMachinesCount.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SummaryCardWidget(
                      title: 'Disabled',
                      value: _controller.archivedMachinesCount.toString(),
                      icon: Icons.cancel,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCardWidget(
                      title: 'Total',
                      value: (_controller.activeMachinesCount +
                              _controller.archivedMachinesCount)
                          .toString(),
                      icon: Icons.devices,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 72, color: Colors.red.shade300),
              const SizedBox(height: 20),
              Text(
                'Error Loading Machines',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage!,
                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.clearError();
                  _controller.initialize();
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.filteredMachines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No Machines Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _controller.searchQuery.isEmpty
                    ? 'You don\'t have any machines yet.'
                    : 'No machines match your search.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _viewMode == 'grid' ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 3
        : screenWidth > 800
            ? 2
            : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _controller.filteredMachines.length,
      itemBuilder: (context, index) {
        final machine = _controller.filteredMachines[index];
        return MachineCardWidget(
          machine: machine,
          onTap: () => _handleMachineTap(machine.machineName),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _controller.filteredMachines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final machine = _controller.filteredMachines[index];
        return MachineListTileWidget(
          machine: machine,
          onTap: () => _handleMachineTap(machine.machineName),
        );
      },
    );
  }
}