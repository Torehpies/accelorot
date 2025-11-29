// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'view_screens/oxygen_stats_view.dart';
import 'view_screens/moisture_stats_view.dart';
import 'view_screens/temperature_stats_view.dart';
import 'widgets/date_filter.dart';
import 'history/history.dart';
import '../../../data/models/machine_model.dart';
import '../../../services/machine_services/firestore_machine_service.dart';
import '../../../services/sess_service.dart';

class StatisticsScreen extends StatefulWidget {
  final String? focusedMachineId;
  final MachineModel? focusedMachine;

  const StatisticsScreen({
    super.key,
    this.focusedMachineId,
    this.focusedMachine,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTimeRange? _selectedRange;
  String _selectedFilterLabel = "Date Filter";
  List<MachineModel> _machines = [];
  List<MachineModel> _filteredMachines = []; // 🔹 For search filtering
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = ""; // 🔹 Current search query

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.focusedMachine != null) {
        _machines = [widget.focusedMachine!];
        _filteredMachines = _machines;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final currentUserId = FirestoreMachineService.getCurrentUserId();

      if (widget.focusedMachineId != null) {
        final allMachines = await FirestoreMachineService.getAllMachines();
        _machines = allMachines
            .where((m) => m.machineId == widget.focusedMachineId)
            .toList();
      } else {
        if (currentUserId != null) {
          final sessionService = SessionService();
          final userData = await sessionService.getCurrentUserData();
          final teamId = userData?['teamId'] as String?;
          if (teamId != null && teamId.isNotEmpty) {
            _machines = await FirestoreMachineService.getMachinesByTeamId(
              teamId,
            );
          } else {
            _machines = await FirestoreMachineService.getAllMachines();
          }
        } else {
          _machines = await FirestoreMachineService.getAllMachines();
        }
      }

      _filteredMachines = _machines; // 🔹 Initialize filtered list

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load machines: $e';
        _isLoading = false;
      });
    }
  }

  void _onDateChanged(DateTimeRange? range) {
    setState(() {
      _selectedRange = range;
      if (range == null) {
        _selectedFilterLabel = "Date Filter";
      } else {
        final daysDiff = range.end.difference(range.start).inDays;
        if (daysDiff == 3) {
          _selectedFilterLabel = "Last 3 Days";
        } else if (daysDiff == 7) {
          _selectedFilterLabel = "Last 7 Days";
        } else if (daysDiff == 14) {
          _selectedFilterLabel = "Last 14 Days";
        } else {
          _selectedFilterLabel =
              "${range.start.month}/${range.start.day} - ${range.end.month}/${range.end.day}";
        }
      }
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedRange = null;
      _selectedFilterLabel = "Date Filter";
      _searchQuery = "";
      _filteredMachines = _machines; // 🔹 Reset search filter
    });
  }

  // 🔹 Handle search input changes
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredMachines = _machines
          .where(
            (m) => m.machineName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusedMachineId != null) {
      return _buildBody();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          if (_selectedRange != null)
            IconButton(
              tooltip: "Reset to Default View",
              icon: const Icon(Icons.refresh),
              onPressed: _resetFilter,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMachines,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _selectedRange == null
          ? _buildAllMachinesLayout()
          : HistoryPage(filter: _selectedFilterLabel, range: _selectedRange!),
    );
  }

  Widget _buildAllMachinesLayout() {
    if (_filteredMachines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                widget.focusedMachineId != null
                    ? 'Machine Not Found'
                    : (_searchQuery.isEmpty
                          ? 'No Machines Found'
                          : 'No Machines match "$_searchQuery"'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.focusedMachineId != null
                    ? 'The selected machine is not available.'
                    : (_searchQuery.isEmpty
                          ? 'You don\'t have any machines assigned yet.'
                          : 'Try adjusting your search.'),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ⭐ Only show summary header when NOT in machine view
        if (widget.focusedMachineId == null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade50, Colors.teal.shade100],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.teal.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring ${_machines.length} machine(s)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        'Active: ${_machines.where((m) => !m.isArchived).length} • Disabled: ${_machines.where((m) => m.isArchived).length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // 🔹 SEARCH BAR
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search Machine',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.teal.shade200),
              ),
              filled: true,
              fillColor: Colors.teal.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // Machine Statistics Cards
        ..._filteredMachines.map((machine) => _buildMachineSection(machine)),
      ],
    );
  }

  Widget _buildMachineSection(MachineModel machine) {
    // ⭐ Simplified card for machine view (no header needed)
    if (widget.focusedMachineId != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            OxygenStatsView(machineId: machine.machineId),
            const SizedBox(height: 12),
            TemperatureStatsView(machineId: machine.machineId),
            const SizedBox(height: 12),
            MoistureStatsView(machineId: machine.machineId),
          ],
        ),
      );
    }

    // ⭐ Full card with header for multi-machine view
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: machine.isArchived ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: machine.isArchived
              ? Colors.grey.shade300
              : Colors.teal.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Machine Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: machine.isArchived
                  ? Colors.grey.shade100
                  : Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  color: machine.isArchived
                      ? Colors.grey.shade600
                      : Colors.teal.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              machine.machineName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: machine.isArchived
                                    ? Colors.grey.shade700
                                    : Colors.teal.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (machine.isArchived)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade300,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'DISABLED',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'ID: ${machine.machineId}',
                        style: TextStyle(
                          fontSize: 10,
                          color: machine.isArchived
                              ? Colors.grey.shade600
                              : Colors.teal.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 DATE FILTER BUTTON INSIDE MACHINE CARD
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade200, // background color
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: DateFilter(onChanged: _onDateChanged),
                  ),
                ),
              ],
            ),
          ),

          // Sensor Readings - Vertical layout for mobile
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                OxygenStatsView(machineId: machine.machineId),
                const SizedBox(height: 8),
                TemperatureStatsView(machineId: machine.machineId),
                const SizedBox(height: 8),
                MoistureStatsView(machineId: machine.machineId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
