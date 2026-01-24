import '../../models/temperature_model.dart';
import '../../models/moisture_model.dart';
import '../../models/oxygen_model.dart';

abstract class StatisticsService {
  Future<List<TemperatureModel>> getTemperatureData(String machineId);
  Future<List<MoistureModel>> getMoistureData(String machineId);
  Future<List<OxygenModel>> getOxygenData(String machineId);
}
