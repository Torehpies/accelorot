import 'package:flutter/material.dart';
import 'temperature_stats_view.dart';
import 'moisture_stats_view.dart';
import 'oxygen_stats_view.dart';

class StatisticsScreen extends StatefulWidget {
  final String? focusedMachineId;

  const StatisticsScreen({
    super.key,
    this.focusedMachineId,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late String _selectedMachineId;

  // Available machines (you can fetch this from a repository later)
  final List<String> _availableMachines = ["01", "02", "03", "04"];

  @override
  void initState() {
    super.initState();
    // Use focusedMachineId if provided, otherwise default to "01"
    _selectedMachineId = widget.focusedMachineId ?? "01";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 20),

                // Machine Selector
                _buildMachineSelector(),
                const SizedBox(height: 24),

                // Statistics Cards
                _buildStatisticsCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time monitoring of your composting machines',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildMachineSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.precision_manufacturing, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Machine',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMachineId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    items: _availableMachines.map((String machineId) {
                      return DropdownMenuItem<String>(
                        value: machineId,
                        child: Text('Machine $machineId'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMachineId = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      children: [
        // Temperature Card
        TemperatureStatsView(machineId: _selectedMachineId),
        const SizedBox(height: 16),

        // Moisture Card
        MoistureStatsView(machineId: _selectedMachineId),
        const SizedBox(height: 16),

        // Oxygen/Air Quality Card
        OxygenStatsView(machineId: _selectedMachineId),
        const SizedBox(height: 16),

        // Summary Card (Optional)
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1ABC9C).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1ABC9C).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Machine Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Last Updated', _formatLastUpdated()),
          const SizedBox(height: 8),
          _buildStatusRow('Machine ID', _selectedMachineId),
          const SizedBox(height: 8),
          _buildStatusRow('Status', 'Active', isActive: true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isActive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            if (isActive) ...[
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF4CAF50) : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleRefresh() async {
    // Trigger refresh by rebuilding with new state
    setState(() {
      // This will cause all child views to reload their data
    });
    
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
  }
}