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
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final padding = width < 600 ? 16.0 : 24.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(width),
                  const SizedBox(height: 24),
                  _buildStatisticsCards(width),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: width < 600
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(),
                const SizedBox(height: 16),
                _buildMachineSelector(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildHeaderContent()),
                const SizedBox(width: 16),
                _buildMachineSelector(),
              ],
            ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
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
            size: 28,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time sensor data and analytics',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
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
          Icon(Icons.analytics, color: Colors.grey[700], size: 18),
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

  Widget _buildStatisticsCards(double width) {
    // Determine layout based on width
    if (width < 700) {
      // Mobile: Single column
      return Column(
        children: [
          _buildTemperatureCard(),
          const SizedBox(height: 20),
          _buildMoistureCard(),
          const SizedBox(height: 20),
          _buildOxygenCard(),
        ],
      );
    } else if (width < 1100) {
      // Tablet: 2 columns
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTemperatureCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildMoistureCard()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOxygenCard()),
              const Expanded(child: SizedBox()), // Empty space
            ],
          ),
        ],
      );
    } else {
      // Desktop: 3 columns
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTemperatureCard()),
          const SizedBox(width: 20),
          Expanded(child: _buildMoistureCard()),
          const SizedBox(width: 20),
          Expanded(child: _buildOxygenCard()),
        ],
      );
    }
  }

  Widget _buildTemperatureCard() {
    final temperatureAsync = ref.watch(
      temperatureDataProvider(_selectedMachineId),
    );

    return _buildSensorCard(
      title: 'Temperature',
      icon: Icons.thermostat,
      iconColor: Colors.orange,
      asyncValue: temperatureAsync,
      builder: (readings) => TemperatureStatisticCard(
        currentTemperature: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(temperatureDataProvider(_selectedMachineId)),
    );
  }

  Widget _buildMoistureCard() {
    final moistureAsync = ref.watch(
      moistureDataProvider(_selectedMachineId),
    );

    return _buildSensorCard(
      title: 'Moisture',
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      asyncValue: moistureAsync,
      builder: (readings) => MoistureStatisticCard(
        currentMoisture: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(moistureDataProvider(_selectedMachineId)),
    );
  }

  Widget _buildOxygenCard() {
    final oxygenAsync = ref.watch(
      oxygenDataProvider(_selectedMachineId),
    );

    return _buildSensorCard(
      title: 'Air Quality',
      icon: Icons.air,
      iconColor: Colors.green,
      asyncValue: oxygenAsync,
      builder: (readings) => OxygenStatisticCard(
        currentOxygen: readings.isNotEmpty ? readings.last.value : 0.0,
        hourlyReadings: readings.map((r) => r.value).toList(),
        lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      ),
      onRetry: () => ref.invalidate(oxygenDataProvider(_selectedMachineId)),
    );
  }

  Widget _buildSensorCard<T>({
    required String title,
    required IconData icon,
    required Color iconColor,
    required AsyncValue<List<T>> asyncValue,
    required Widget Function(List<T>) builder,
    required VoidCallback onRetry,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: asyncValue.when(
              data: (readings) => builder(readings),
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stack) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 36, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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