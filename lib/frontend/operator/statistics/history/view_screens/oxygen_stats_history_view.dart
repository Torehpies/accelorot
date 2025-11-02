import 'package:flutter/material.dart';
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

  @override
  void didUpdateWidget(OxygenStatsHistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) {
      _fetchOxygenHistory();
    }
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
      double? lastKnownValue;

      final daysDiff = end.difference(start).inDays + 1;

      for (int i = 0; i < daysDiff; i++) {
        final currentDay = start.add(Duration(days: i));
        final dateKey = '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
        
        labels.add(dateKey);

        if (dataByDay.containsKey(dateKey)) {
          final dayValues = dataByDay[dateKey]!.map((d) => d['value'] as double).toList();

          if (dayValues.isNotEmpty) {
            final dailyAvg = dayValues.reduce((a, b) => a + b) / dayValues.length;
            readings.add(dailyAvg);
            lastKnownValue = dailyAvg;

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
          }
        } else {
          readings.add(0.0);
          debugPrint('⚠️ $dateKey – no readings, using 0.0');
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