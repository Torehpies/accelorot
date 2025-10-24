import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../services/firestore_statistic_history_service.dart';
import '../widgets/moisture_statistic_history_card.dart';

class MoistureStatsHistoryView extends StatefulWidget {
  final String machineId;
  final DateTimeRange? range;
  final List<String>? labels;

  const MoistureStatsHistoryView({
    super.key,
    required this.machineId,
    this.range,
    this.labels,
  });

  @override
  State<MoistureStatsHistoryView> createState() =>
      _MoistureStatsHistoryViewState();
}

class _MoistureStatsHistoryViewState extends State<MoistureStatsHistoryView> {
  bool _isLoading = true;
  List<double> _dailyReadings = [];
  List<String> _labels = [];
  DateTime? _lastUpdated;
  double _currentMoisture = 0.0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchMoistureHistory();
  }

  Future<void> _fetchMoistureHistory() async {
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
        fieldName: 'moisture',
        start: start,
        end: end,
      );

      final List<double> readings = [];
      final List<String> labels = [];
      DateTime? lastUpdate;

      // Only include days that have readings
      for (var entry in dataByDay.entries) {
        final dayValues = entry.value.map((d) => d['value'] as double).toList();

        if (dayValues.isNotEmpty) {
          final dailyAvg = dayValues.reduce((a, b) => a + b) / dayValues.length;
          readings.add(dailyAvg);
          labels.add(entry.key); // store date label

          // track last update timestamp
          for (var d in entry.value) {
            final ts = d['timestamp'] as DateTime?;
            if (ts != null && (lastUpdate == null || ts.isAfter(lastUpdate))) {
              lastUpdate = ts;
            }
          }

          debugPrint('📊 ${entry.key} – dailyAvg: $dailyAvg, readings: $dayValues');
        } else {
          debugPrint('⚠️ ${entry.key} – no readings, skipping');
        }
      }

      setState(() {
        _dailyReadings = readings;
        _labels = labels;
        _lastUpdated = lastUpdate;
        _currentMoisture = readings.isNotEmpty ? readings.last : 0.0;
        _isLoading = false;
      });
    } catch (e, stack) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ Error loading moisture history: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    if (_dailyReadings.isEmpty) return const Center(child: Text('No moisture data available'));

    return Column(
      children: [
        MoistureStatisticHistoryCard(
          currentMoisture: _currentMoisture,
          dailyReadings: _dailyReadings,
          lastUpdated: _lastUpdated,
          labels: _labels, // pass only dates with data
        ),
        const SizedBox(height: 8),
        Text(
          'Showing ${_labels.length} days with data',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
