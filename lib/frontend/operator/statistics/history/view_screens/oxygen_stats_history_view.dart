import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../services/firestore_statistic_history_service.dart';
import '../widgets/oxygen_statistic_history_card.dart';

class OxygenStatsHistoryView extends StatefulWidget {
  final String machineId;
  final DateTimeRange? range;
  final List<String>? labels;

  const OxygenStatsHistoryView({
    super.key,
    required this.machineId,
    this.range,
    this.labels,
  });

  @override
  State<OxygenStatsHistoryView> createState() => _OxygenStatsHistoryViewState();
}

class _OxygenStatsHistoryViewState extends State<OxygenStatsHistoryView> {
  bool _isLoading = true;
  List<double> _dailyReadings = [];
  List<String> _labels = [];
  DateTime? _lastUpdated;
  double _currentOxygen = 0.0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchOxygenHistory();
  }

  Future<void> _fetchOxygenHistory() async {
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
        fieldName: 'oxygen',
        start: start,
        end: end,
      );

      final List<double> readings = [];
      final List<String> labels = [];
      DateTime? lastUpdate;

      for (var entry in dataByDay.entries) {
        final dayValues = entry.value.map((d) => d['value'] as double).toList();

        if (dayValues.isNotEmpty) {
          final dailyAvg = dayValues.reduce((a, b) => a + b) / dayValues.length;
          readings.add(dailyAvg);
          labels.add(entry.key); // store only days with data

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
        _currentOxygen = readings.isNotEmpty ? readings.last : 0.0;
        _isLoading = false;
      });
    } catch (e, stack) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ Error loading oxygen history: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    if (_dailyReadings.isEmpty) return const Center(child: Text('No oxygen data available'));

    return Column(
      children: [
        OxygenStatisticHistoryCard(
          currentOxygen: _currentOxygen,
          dailyReadings: _dailyReadings,
          lastUpdated: _lastUpdated,
          labels: _labels, // only show days with readings
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
