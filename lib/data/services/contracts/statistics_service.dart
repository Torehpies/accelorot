import '../../models/temperature_model.dart';
import '../../models/moisture_model.dart';
import '../../models/oxygen_model.dart';

abstract class StatisticsService {
  Future<List<TemperatureModel>> getTemperatureData(String batchId);
  Future<List<MoistureModel>> getMoistureData(String batchId);
  Future<List<OxygenModel>> getOxygenData(String batchId);
}
