import '../models/temperature_model.dart';
import '../models/moisture_model.dart';
import '../models/oxygen_model.dart';
import '../services/contracts/statistics_service_contract.dart';
import 'contracts/statistics_repository_contract.dart';

class StatisticsRepository implements StatisticsRepositoryContract {
  final StatisticsServiceContract _statisticsService;

  StatisticsRepository({
    required StatisticsServiceContract statisticsService,
  }) : _statisticsService = statisticsService;

  @override
  Future<List<TemperatureModel>> getTemperatureReadings(
    String machineId,
  ) async {
    try {
      final rawData = await _statisticsService.getTemperatureData(machineId);
      return rawData.map((data) => TemperatureModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch temperature readings: $e');
    }
  }

  @override
  Future<List<MoistureModel>> getMoistureReadings(String machineId) async {
    try {
      final rawData = await _statisticsService.getMoistureData(machineId);
      return rawData.map((data) => MoistureModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch moisture readings: $e');
    }
  }

  @override
  Future<List<OxygenModel>> getOxygenReadings(String machineId) async {
    try {
      final rawData = await _statisticsService.getOxygenData(machineId);
      return rawData.map((data) => OxygenModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch oxygen readings: $e');
    }
  }
}