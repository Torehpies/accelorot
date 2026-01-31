import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/statistics_providers.dart';
import 'widgets/oxygen_statistic_card.dart';

class OxygenStatsView extends ConsumerWidget {
  final String? machineId;

  const OxygenStatsView({super.key, this.machineId});

  static const String _defaultMachineId = "01";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oxygenAsync = ref.watch(
      oxygenDataProvider(machineId ?? _defaultMachineId),
    );

    return oxygenAsync.when(
      data: (readings) {
        final currentOxygen = readings.isNotEmpty ? readings.last.value : 0.0;
        final hourlyReadings = readings.map((r) => r.value).toList();
        final lastUpdated = readings.isNotEmpty
            ? readings.last.timestamp
            : null;

        return OxygenStatisticCard(
          currentOxygen: currentOxygen,
          readings: readings,
          lastUpdated: lastUpdated,
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 24, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text(
                'Error loading data',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () => ref.invalidate(
                  oxygenDataProvider(machineId ?? _defaultMachineId),
                ),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Retry', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
