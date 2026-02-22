import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/statistics_providers.dart';
import 'sensor_trend_chart.dart';

enum SensorType { temperature, moisture, oxygen }

class SensorTrendView extends ConsumerWidget {
  final String batchId;
  final SensorType sensorType;

  const SensorTrendView({
    super.key,
    required this.batchId,
    required this.sensorType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (batchId.isEmpty) {
      return const Center(child: Text('No active batch selected.'));
    }

    AsyncValue<List<dynamic>> asyncData;

    switch (sensorType) {
      case SensorType.temperature:
        asyncData = ref.watch(temperatureDataProvider(batchId));
        break;
      case SensorType.moisture:
        asyncData = ref.watch(moistureDataProvider(batchId));
        break;
      case SensorType.oxygen:
        asyncData = ref.watch(oxygenDataProvider(batchId));
        break;
    }

    return asyncData.when(
      data: (readings) {
        if (readings.isEmpty) {
          return const Center(child: Text('No historical data recorded yet.'));
        }

        final chartData = _generateDailyData(readings);
        
        switch (sensorType) {
          case SensorType.temperature:
            return SensorTrendChart(
              chartData: chartData,
              mainColor: const Color(0xFFEA580C),
              unit: '°C',
              maxY: 100,
            );
          case SensorType.moisture:
            return SensorTrendChart(
              chartData: chartData,
              mainColor: const Color(0xFF0284C7),
              unit: '%',
              maxY: 100,
            );
          case SensorType.oxygen:
            return SensorTrendChart(
              chartData: chartData,
              mainColor: const Color(0xFF7C3AED),
              unit: ' ppm',
              maxY: 5000,
              isPPM: true,
            );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading trend: $e')),
    );
  }

  List<Map<String, dynamic>> _generateDailyData(List<dynamic> readings) {
    if (readings.isEmpty) return [];

    final sortedReadings = List<dynamic>.from(readings);
    sortedReadings.sort((a, b) => (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));

    final firstDate = sortedReadings.first.timestamp ?? DateTime.now();
    final startDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    
    final List<Map<String, dynamic>> data = [];
    final Map<int, List<Map<String, dynamic>>> dayGroups = {};

    for (int i = 0; i < sortedReadings.length; i++) {
      final reading = sortedReadings[i];
      final date = reading.timestamp ?? DateTime.now();
      final diff = date.difference(startDate);
      final double dayValue = diff.inSeconds / (24 * 3600);
      final int dayInt = dayValue.floor();

      if (!dayGroups.containsKey(dayInt)) {
        dayGroups[dayInt] = [];
      }
      
      dayGroups[dayInt]!.add({
        'day': dayValue,
        'value': reading.value,
        'timestamp': date,
      });
    }

    dayGroups.forEach((day, points) {
      if (points.isEmpty) return;
      
      points.sort((a, b) => (a['day'] as double).compareTo(b['day'] as double));
      
      final start = points.first;
      final end = points.last;
      
      var minPoint = points.first;
      var maxPoint = points.first;
      
      for (var point in points) {
        if ((point['value'] as double) < (minPoint['value'] as double)) {
          minPoint = point;
        }
        if ((point['value'] as double) > (maxPoint['value'] as double)) {
          maxPoint = point;
        }
      }
      
      final uniquePoints = <Map<String, dynamic>>{};
      
      uniquePoints.add({...start, 'isMarker': true});
      
      if (minPoint != start && minPoint != end) {
        uniquePoints.add({...minPoint, 'isMarker': false});
      }
      
      if (maxPoint != start && maxPoint != end) {
        uniquePoints.add({...maxPoint, 'isMarker': false});
      }
      
      if (end != start) {
        uniquePoints.add({...end, 'isMarker': false});
      }
      
      final dayData = uniquePoints.toList();
      dayData.sort((a, b) => (a['day'] as double).compareTo(b['day'] as double));
      data.addAll(dayData);
    });

    return data;
  }
}
