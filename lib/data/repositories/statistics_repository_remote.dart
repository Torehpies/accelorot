import '../models/temperature_model.dart';
import '../models/moisture_model.dart';
import '../models/oxygen_model.dart';
import '../services/contracts/statistics_service.dart';
import 'contracts/statistics_repository.dart';

class StatisticsRepositoryRemote implements StatisticsRepository {
  final StatisticsService _statisticsService;

  StatisticsRepositoryRemote({
    required StatisticsService statisticsService,
  }) : _statisticsService = statisticsService;

  @override
  Future<List<TemperatureModel>> getTemperatureReadings(
    String batchId,
  ) async {
    // Service handles all error handling and returns typed models
    return await _statisticsService.getTemperatureData(batchId);
  }

  @override
  Future<List<MoistureModel>> getMoistureReadings(String batchId) async {
    // Service handles all error handling and returns typed models
    return await _statisticsService.getMoistureData(batchId);
  }

  @override
  Future<List<OxygenModel>> getOxygenReadings(String batchId) async {
    // Service handles all error handling and returns typed models
    return await _statisticsService.getOxygenData(batchId);
  }
}