import '../models/temperature_model.dart';
import '../models/moisture_model.dart';
import '../models/oxygen_model.dart';
import '../services/contracts/statistics_service.dart';
import 'contracts/statistics_repository.dart';

class StatisticsRepositoryRemote implements StatisticsRepository {
  final StatisticsService _statisticsService;

  StatisticsRepositoryRemote({required StatisticsService statisticsService})
    : _statisticsService = statisticsService;

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

  @override
  Future<Map<String, dynamic>?> getLatestSensorReadings(String batchId) async {
    return await _statisticsService.getLatestSensorReadings(batchId);
  }

  @override
  Stream<List<TemperatureModel>> getTemperatureReadingsStream(String batchId) {
    return _statisticsService.getTemperatureDataStream(batchId);
  }

  @override
  Stream<List<MoistureModel>> getMoistureReadingsStream(String batchId) {
    return _statisticsService.getMoistureDataStream(batchId);
  }

  @override
  Stream<List<OxygenModel>> getOxygenReadingsStream(String batchId) {
    return _statisticsService.getOxygenDataStream(batchId);
  }

  @override
  Stream<Map<String, dynamic>?> getLatestSensorReadingsStream(String batchId) {
    return _statisticsService.getLatestSensorReadingsStream(batchId);
  }
}
