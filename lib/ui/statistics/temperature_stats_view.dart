import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/statistics_providers.dart';
import 'widgets/temperature_statistic_card.dart';

class TemperatureStatsView extends ConsumerWidget {
  final String? machineId;

  const TemperatureStatsView({super.key, this.machineId});

  static const String _defaultMachineId = "01";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temperatureAsync = ref.watch(
      temperatureDataProvider(machineId ?? _defaultMachineId),
    );

    return temperatureAsync.when(
      data: (readings) {
        final currentTemp = readings.isNotEmpty ? readings.last.value : 0.0;
        final hourlyReadings = readings.map((r) => r.value).toList();
        final lastUpdated = readings.isNotEmpty
            ? readings.last.timestamp
            : null;

        return SizedBox(
          height: 300,
          child: TemperatureStatisticCard(
            currentTemperature: currentTemp,
            hourlyReadings: hourlyReadings,
            lastUpdated: lastUpdated,
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Error loading data',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(
                  temperatureDataProvider(machineId ?? _defaultMachineId),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
