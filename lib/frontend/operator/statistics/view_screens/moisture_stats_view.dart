import 'package:flutter/material.dart';
import '../../../../services/firestore_statistics_service.dart';
import '../widgets/moisture_statistic_card.dart';

class MoistureStatsView extends StatefulWidget {
  const MoistureStatsView({super.key});

  @override
  State<MoistureStatsView> createState() => _MoistureStatsViewState();
}

class _MoistureStatsViewState extends State<MoistureStatsView> {
  double _currentMoisture = 0;
  List<double> _hourlyReadings = [];
  DateTime? _lastUpdated;
  bool _isLoading = true;
  String? _errorMessage;

  static const String _machineId = "01";

  @override
  void initState() {
    super.initState();
    _loadMoistureData();
  }

  Future<void> _loadMoistureData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await FirestoreStatisticsService.getMoistureData(_machineId);

      if (data.isNotEmpty) {
        _hourlyReadings = data.map((e) => e['value'] as double).toList();
        _currentMoisture = _hourlyReadings.last;
        _lastUpdated = data.last['timestamp'];
      } else {
        // ✅ Treat “no data” as empty — not an error
        _hourlyReadings = [];
        _currentMoisture = 0;
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

    // ❌ Only show this when there’s an *actual error* (e.g., connection failure)
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
                onPressed: _loadMoistureData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Always show the MoistureStatisticCard, even with no data
    return SizedBox(
      height: 300,
      child: MoistureStatisticCard(
        currentMoisture: _currentMoisture,
        hourlyReadings: _hourlyReadings,
        lastUpdated: _lastUpdated,
      ),
    );
  }
}
