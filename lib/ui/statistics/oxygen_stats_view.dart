import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/firebase/firestore_statistics_service.dart';
import 'view_models/oxygen_view_model.dart';
import 'widgets/oxygen_statistic_card.dart';

class OxygenStatsView extends StatelessWidget {
  final String? machineId;

  const OxygenStatsView({super.key, this.machineId});

  static const String _defaultMachineId = "01";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = FirestoreStatisticsService();
        final repository = StatisticsRepository(statisticsService: service);
        final viewModel = OxygenViewModel(
          repository: repository,
          machineId: machineId ?? _defaultMachineId,
        );
        viewModel.loadData();
        return viewModel;
      },
      child: Consumer<OxygenViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          if (viewModel.errorMessage != null) {
            return SizedBox(
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
                      onPressed: viewModel.loadData,
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
            );
          }

          return OxygenStatisticCard(
            currentOxygen: viewModel.currentOxygen,
            hourlyReadings: viewModel.hourlyReadings,
            lastUpdated: viewModel.lastUpdated,
          );
        },
      ),
    );
  }
}