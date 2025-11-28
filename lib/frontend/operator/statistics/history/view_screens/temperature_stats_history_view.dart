import 'package:flutter/material.dart';
import '../../../../../services/firestore_statistic_history_service.dart';
import '../widgets/temperature_statistic_history_card.dart';

class TemperatureStatsHistoryView extends StatefulWidget {
  final String machineId;
  final DateTimeRange? range;
  final List<String>? labels;

  const TemperatureStatsHistoryView({
    super.key,
    required this.machineId,
    this.range,
    this.labels,
  });

  @override
  State<TemperatureStatsHistoryView> createState() =>
      _TemperatureStatsHistoryViewState();
}

class _TemperatureStatsHistoryViewState
    extends State<TemperatureStatsHistoryView> {
  bool _isLoading = true;
  List<double> _dailyReadings = [];
  List<String> _labels = [];
  DateTime? _lastUpdated;
  double _currentTemperature = 0.0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTemperatureHistory();
  }

  @override
  void didUpdateWidget(TemperatureStatsHistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) {
      _fetchTemperatureHistory();
    }
  }

  Future<void> _fetchTemperatureHistory() async {
  try {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final now = DateTime.now();
    final start = widget.range?.start ?? now.subtract(const Duration(days: 7));
    final end = widget.range?.end ?? now;

    final dataByDay = await FirestoreStatisticHistoryService.getDataForRange(
      machineId: widget.machineId,
      fieldName: 'temp',
      start: start,
      end: end,
    );

    final List<double> readings = [];
    final List<String> labels = [];
    DateTime? lastUpdate;
    double? latestValidTemperature; // ✅ Track the latest actual reading

    final daysDiff = end.difference(start).inDays + 1;

    for (int i = 0; i < daysDiff; i++) {
      final currentDay = start.add(Duration(days: i));
      final dateKey = '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
      
      labels.add(dateKey);

      if (dataByDay.containsKey(dateKey) && dataByDay[dateKey]!.isNotEmpty) {
        final dayValues = dataByDay[dateKey]!.map((d) => d['value'] as double).toList();
        final dailyAvg = dayValues.reduce((a, b) => a + b) / dayValues.length;
        readings.add(dailyAvg);

        // Update latest valid temperature
        latestValidTemperature = dailyAvg;

        // Update lastUpdate timestamp
        for (var d in dataByDay[dateKey]!) {
          final ts = d['timestamp'] as DateTime?;
          if (ts != null && (lastUpdate == null || ts.isAfter(lastUpdate))) {
            lastUpdate = ts;
          }
        }

        debugPrint('📊 $dateKey – dailyAvg: $dailyAvg, readings: $dayValues');
      } else {
        readings.add(0.0);
        debugPrint('⚠️ $dateKey – no readings, using 0.0');
        // Do NOT update latestValidTemperature — keep the last known real value
      }
    }

    // Fallback: if no valid data at all, use 0.0
    final currentTemp = latestValidTemperature ?? (readings.isNotEmpty ? readings.last : 0.0);

    setState(() {
      _dailyReadings = readings;
      _labels = labels;
      _lastUpdated = lastUpdate;
      _currentTemperature = currentTemp;
      _isLoading = false;
    });
  } catch (e, stack) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
    debugPrint('❌ Error loading temperature history: $e\n$stack');
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_dailyReadings.isEmpty) {
      return const Center(child: Text('No temperature data available'));
    }

    return Column(
      children: [
        TemperatureStatisticHistoryCard(
          currentTemperature: _currentTemperature,
          dailyReadings: _dailyReadings,
          lastUpdated: _lastUpdated,
          labels: _labels,
        ),
        const SizedBox(height: 8),
        Text(
          'Showing ${_labels.length} days',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
