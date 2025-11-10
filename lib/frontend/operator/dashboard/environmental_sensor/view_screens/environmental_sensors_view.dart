// lib/frontend/operator/views/environmental_sensors_view.dart
import 'package:flutter/material.dart';
import '../../../../../services/firestore_statistics_service.dart';
import '../widgets/environmental_sensors_card.dart';

class EnvironmentalSensorsView extends StatefulWidget {
  const EnvironmentalSensorsView({super.key});

  @override
  State<EnvironmentalSensorsView> createState() =>
      _EnvironmentalSensorsViewState();
}

class _EnvironmentalSensorsViewState extends State<EnvironmentalSensorsView> {
  double? _temperature;
  double? _moisture;
  double? _oxygen;

  List<double> _temperatureReadings = [];
  List<double> _moistureReadings = [];
  List<double> _oxygenReadings = [];

  bool _isLoading = true;
  String? _errorMessage;

  static const String _machineId = "01";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tempData = await FirestoreStatisticsService.getTemperatureData(
        _machineId,
      );
      final moistureData = await FirestoreStatisticsService.getMoistureData(
        _machineId,
      );
      final oxygenData = await FirestoreStatisticsService.getOxygenData(
        _machineId,
      );

      // Convert readings (even if empty)
      _temperatureReadings = tempData.map((e) => e['value'] as double).toList();
      _moistureReadings = moistureData
          .map((e) => e['value'] as double)
          .toList();
      _oxygenReadings = oxygenData.map((e) => e['value'] as double).toList();

      _temperature = _temperatureReadings.isNotEmpty
          ? _temperatureReadings.last
          : null;
      _moisture = _moistureReadings.isNotEmpty ? _moistureReadings.last : null;
      _oxygen = _oxygenReadings.isNotEmpty ? _oxygenReadings.last : null;
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _calculateChange(List<double> readings) {
    if (readings.length < 2) return '+0 this week';
    final diff = readings.last - readings.first;
    return '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} this week';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ⚠️ Only show this if a real Firestore/network error occurred
    if (_errorMessage != null && _errorMessage!.startsWith('Error')) {
      return SizedBox(
        height: 210,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Always show the card — even if all data is missing
    return EnvironmentalSensorsCard(
      temperature: _temperature,
      moisture: _moisture,
      oxygen: _oxygen,
      temperatureChange: _calculateChange(_temperatureReadings),
      moistureChange: _calculateChange(_moistureReadings),
      oxygenChange: _calculateChange(_oxygenReadings),
    );
  }
}
