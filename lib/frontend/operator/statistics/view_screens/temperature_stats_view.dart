import 'package:flutter/material.dart';
import '../../../../services/firestore_statistics_service.dart';
import '../widgets/temperature_statistic_card.dart';

class TemperatureStatsView extends StatefulWidget {
  final String? machineId;

  const TemperatureStatsView({super.key, this.machineId});

  @override
  State<TemperatureStatsView> createState() => _TemperatureStatsViewState();
}

class _TemperatureStatsViewState extends State<TemperatureStatsView> {
  double _currentTemperature = 0;
  List<double> _hourlyReadings = [];
  DateTime? _lastUpdated;
  bool _isLoading = true;
  String? _errorMessage;

  static const String _defaultMachineId = "01";

  String get _machineId => widget.machineId ?? _defaultMachineId;

  @override
  void initState() {
    super.initState();
    _loadTemperatureData();
  }

  @override
  void didUpdateWidget(TemperatureStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machineId != widget.machineId) {
      _loadTemperatureData();
    }
  }

  Future<void> _loadTemperatureData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await FirestoreStatisticsService.getTemperatureData(
        _machineId,
      );

      if (data.isNotEmpty) {
        _hourlyReadings = data.map((e) => e['value'] as double).toList();
        _currentTemperature = _hourlyReadings.last;
        _lastUpdated = data.last['timestamp'];
      } else {
        _hourlyReadings = [];
        _currentTemperature = 0;
        _lastUpdated = null;
      }
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 200,
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
                onPressed: _loadTemperatureData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: TemperatureStatisticCard(
        currentTemperature: _currentTemperature,
        hourlyReadings: _hourlyReadings,
        lastUpdated: _lastUpdated,
      ),
    );
  }
}
