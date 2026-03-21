import '../../models/temperature_model.dart';
import '../../models/moisture_model.dart';
import '../../models/oxygen_model.dart';

abstract class StatisticsRepository {
  Future<List<TemperatureModel>> getTemperatureReadings(String batchId);
  Future<List<MoistureModel>> getMoistureReadings(String batchId);
  Future<List<OxygenModel>> getOxygenReadings(String batchId);
  Future<Map<String, dynamic>?> getLatestSensorReadings(String batchId);

  // Stream-based methods for real-time updates
  Stream<List<TemperatureModel>> getTemperatureReadingsStream(String batchId);
  Stream<List<MoistureModel>> getMoistureReadingsStream(String batchId);
  Stream<List<OxygenModel>> getOxygenReadingsStream(String batchId);
  Stream<Map<String, dynamic>?> getLatestSensorReadingsStream(String batchId);
}
