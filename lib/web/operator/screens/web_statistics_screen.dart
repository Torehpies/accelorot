// lib/frontend/operator/web/web_statistics_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/statistics/view_screens/oxygen_stats_view.dart';
import '../../../frontend/operator/statistics/view_screens/moisture_stats_view.dart';
import '../../../frontend/operator/statistics/view_screens/temperature_stats_view.dart';
import '../../../frontend/operator/statistics/widgets/date_filter.dart';
import '../../../frontend/operator/statistics/history/history.dart';
import '../../../frontend/operator/machine_management/models/machine_model.dart';
import '../../../services/machine_services/firestore_machine_service.dart';
import '../../../services/sess_service.dart';

class WebStatisticsScreen extends StatefulWidget {


  const WebStatisticsScreen({super.key});

  @override
  State<WebStatisticsScreen> createState() => _WebStatisticsScreenState();
}

class _WebStatisticsScreenState extends State<WebStatisticsScreen> {
  DateTimeRange? _selectedRange;
  String _selectedFilterLabel = "Date Filter";
  List<MachineModel> _machines = [];
  bool _isLoading = true;
  String? _errorMessage;

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


      final currentUserId = FirestoreMachineService.getCurrentUserId();
      // ⭐ Load machines by user's teamId
      if (currentUserId != null) {
        // Get user's teamId and fetch team machines
        final sessionService = SessionService();
        final userData = await sessionService.getCurrentUserData();
        final teamId = userData?['teamId'] as String?;
        
        if (teamId != null && teamId.isNotEmpty) {
          _machines = await FirestoreMachineService.getMachinesByTeamId(teamId);
        } else {
          _machines = await FirestoreMachineService.getAllMachines();
        }
      } else {
        _machines = await FirestoreMachineService.getAllMachines();
      }

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
    });
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
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DateFilter(onChanged: _onDateChanged),
          ),
          if (_selectedRange != null)
            IconButton(
              tooltip: "Reset to Default View",
              icon: const Icon(Icons.refresh),
              onPressed: _resetFilter,
            ),
          IconButton(
            tooltip: "Refresh Data",
            icon: const Icon(Icons.refresh),
            onPressed: _loadMachines,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadMachines,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isWideScreen ? 24 : 12),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: _selectedRange == null
                            ? _buildAllMachinesLayout()
                            : HistoryPage(
                                filter: _selectedFilterLabel,
                                range: _selectedRange!,
                              ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildAllMachinesLayout() {
    if (_machines.isEmpty) {
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
                'You don\'t have any machines assigned yet.',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.teal.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.teal.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Machines Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitoring ${_machines.length} machine(s) | Active: ${_machines.where((m) => !m.isArchived).length} | Disabled: ${_machines.where((m) => m.isArchived).length}',
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

        // Machine Statistics Cards
        ..._machines.map((machine) => _buildMachineSection(machine)),
      ],
    );
  }

  Widget _buildMachineSection(MachineModel machine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Machine Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: machine.isArchived ? Colors.grey.shade100 : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: machine.isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.precision_manufacturing,
                color: machine.isArchived ? Colors.grey : Colors.teal.shade700,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          machine.machineName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: machine.isArchived ? Colors.grey.shade700 : Colors.teal.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (machine.isArchived)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cancel, size: 12, color: Colors.orange.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'DISABLED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Machine ID: ${machine.machineId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: machine.isArchived ? Colors.grey.shade600 : Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sensor Readings
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: machine.isArchived ? Colors.grey.shade50 : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(
                color: machine.isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
                width: 2,
              ),
              right: BorderSide(
                color: machine.isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
                width: 2,
              ),
              bottom: BorderSide(
                color: machine.isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
                width: 2,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              
              if (isWide) {
                // Horizontal layout for wide screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: OxygenStatsView(machineId: machine.machineId),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TemperatureStatsView(machineId: machine.machineId),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MoistureStatsView(machineId: machine.machineId),
                    ),
                  ],
                );
              } else {
                // Vertical layout for narrow screens
                return Column(
                  children: [
                    OxygenStatsView(machineId: machine.machineId),
                    const SizedBox(height: 16),
                    TemperatureStatsView(machineId: machine.machineId),
                    const SizedBox(height: 16),
                    MoistureStatsView(machineId: machine.machineId),
                  ],
                );
              }
            },
          ),
        ),

        const SizedBox(height: 20), // Space between machines
      ],
    );
  }
}