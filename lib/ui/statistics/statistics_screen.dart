import 'package:flutter/material.dart';
import 'temperature_stats_view.dart';
import 'moisture_stats_view.dart';
import 'oxygen_stats_view.dart';

class StatisticsScreen extends StatefulWidget {
  final String? focusedMachineId;

  const StatisticsScreen({super.key, this.focusedMachineId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late String _selectedMachineId;
  final List<String> _availableMachines = ["01", "02", "03", "04"];

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.focusedMachineId ?? "01";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // 🔹 Machine Selector
            _buildMachineSelector(),
            const SizedBox(height: 12),

            // 🔹 Sensor Cards like old UI
            _buildMachineCard(_selectedMachineId, 'Machine $_selectedMachineId', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.precision_manufacturing, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMachineId,
                isExpanded: true,
                items: _availableMachines.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('Machine $m'),
                )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMachineId = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMachineCard(String id, String name, bool isArchived) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isArchived ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isArchived ? Colors.grey.shade300 : Colors.teal.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isArchived ? Colors.grey.shade100 : Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 16,
                  color: isArchived ? Colors.grey.shade600 : Colors.teal.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isArchived ? Colors.grey.shade700 : Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        'ID: $id',
                        style: TextStyle(
                          fontSize: 10,
                          color: isArchived ? Colors.grey.shade600 : Colors.teal.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sensor Stats stacked vertically
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                OxygenStatsView(machineId: id),
                const SizedBox(height: 8),
                TemperatureStatsView(machineId: id),
                const SizedBox(height: 8),
                MoistureStatsView(machineId: id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
