import '../../models/temperature_model.dart';
import '../../models/moisture_model.dart';
import '../../models/oxygen_model.dart';

abstract class StatisticsRepository{
  Future<List<TemperatureModel>> getTemperatureReadings(String machineId);
  Future<List<MoistureModel>> getMoistureReadings(String machineId);
  Future<List<OxygenModel>> getOxygenReadings(String machineId);
}