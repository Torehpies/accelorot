import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/firebase/firestore_statistics_service.dart';
import 'view_models/temperature_view_model.dart';
import 'widgets/temperature_statistic_card.dart';

class TemperatureStatsView extends StatelessWidget {
  final String? machineId;

  const TemperatureStatsView({super.key, this.machineId});

  static const String _defaultMachineId = "01";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = FirestoreStatisticsService();
        final repository = StatisticsRepository(statisticsService: service);
        final viewModel = TemperatureViewModel(
          repository: repository,
          machineId: machineId ?? _defaultMachineId,
        );
        viewModel.loadData();
        return viewModel;
      },
      child: Consumer<TemperatureViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.errorMessage != null) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: viewModel.loadData,
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
              currentTemperature: viewModel.currentTemperature,
              hourlyReadings: viewModel.hourlyReadings,
              lastUpdated: viewModel.lastUpdated,
            ),
          );
        },
      ),
    );
  }
}