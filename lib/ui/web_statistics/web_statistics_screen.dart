
// web_statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/statistics_providers.dart';
import '../mobile_statistics/widgets/temperature_statistic_card.dart';
import '../mobile_statistics/widgets/moisture_statistic_card.dart';
import '../mobile_statistics/widgets/oxygen_statistic_card.dart';

class WebStatisticsScreen extends ConsumerStatefulWidget {
  final String? focusedMachineId;

  const WebStatisticsScreen({super.key, this.focusedMachineId});

  @override
  ConsumerState<WebStatisticsScreen> createState() => _WebStatisticsScreenState();
}

class _WebStatisticsScreenState extends ConsumerState<WebStatisticsScreen> {
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Machine Selector
              _buildHeader(),
              const SizedBox(height: 24),

              // Statistics Grid
              _buildStatisticsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.precision_manufacturing,
              color: Colors.teal.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Machine Monitoring',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time sensor data and analytics',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildMachineSelector(),
        ],
      ),
    );
  }

  Widget _buildMachineSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMachineId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              items: _availableMachines.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text('Machine $m'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMachineId = val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 1 column for narrow, 2 for medium, 3 for wide
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.4,
          children: [
            _buildTemperatureCard(),
            _buildMoistureCard(),
            _buildOxygenCard(),
          ],
        );
      },
    );
  }

  Widget _buildTemperatureCard() {
    final temperatureAsync = ref.watch(
      temperatureDataProvider(_selectedMachineId),
    );

    return _buildCardWrapper(
      title: 'Temperature',
      icon: Icons.thermostat,
      iconColor: Colors.orange,
      child: temperatureAsync.when(
        data: (readings) {
          final currentTemp = readings.isNotEmpty ? readings.last.value : 0.0;
          final hourlyReadings = readings.map((r) => r.value).toList();
          final lastUpdated =
              readings.isNotEmpty ? readings.last.timestamp : null;

          return TemperatureStatisticCard(
            currentTemperature: currentTemp,
            hourlyReadings: hourlyReadings,
            lastUpdated: lastUpdated,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => _buildErrorState(
          onRetry: () => ref.invalidate(
            temperatureDataProvider(_selectedMachineId),
          ),
        ),
      ),
    );
  }

  Widget _buildMoistureCard() {
    final moistureAsync = ref.watch(
      moistureDataProvider(_selectedMachineId),
    );

    return _buildCardWrapper(
      title: 'Moisture',
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      child: moistureAsync.when(
        data: (readings) {
          final currentMoisture =
              readings.isNotEmpty ? readings.last.value : 0.0;
          final hourlyReadings = readings.map((r) => r.value).toList();
          final lastUpdated =
              readings.isNotEmpty ? readings.last.timestamp : null;

          return MoistureStatisticCard(
            currentMoisture: currentMoisture,
            hourlyReadings: hourlyReadings,
            lastUpdated: lastUpdated,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => _buildErrorState(
          onRetry: () => ref.invalidate(
            moistureDataProvider(_selectedMachineId),
          ),
        ),
      ),
    );
  }

  Widget _buildOxygenCard() {
    final oxygenAsync = ref.watch(
      oxygenDataProvider(_selectedMachineId),
    );

    return _buildCardWrapper(
      title: 'Air Quality',
      icon: Icons.air,
      iconColor: Colors.green,
      child: oxygenAsync.when(
        data: (readings) {
          final currentOxygen = readings.isNotEmpty ? readings.last.value : 0.0;
          final hourlyReadings = readings.map((r) => r.value).toList();
          final lastUpdated =
              readings.isNotEmpty ? readings.last.timestamp : null;

          return OxygenStatisticCard(
            currentOxygen: currentOxygen,
            hourlyReadings: hourlyReadings,
            lastUpdated: lastUpdated,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => _buildErrorState(
          onRetry: () => ref.invalidate(
            oxygenDataProvider(_selectedMachineId),
          ),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.1 * 255).round()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor.withAlpha((0.9 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Error loading data',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(temperatureDataProvider(_selectedMachineId));
    ref.invalidate(moistureDataProvider(_selectedMachineId));
    ref.invalidate(oxygenDataProvider(_selectedMachineId));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}