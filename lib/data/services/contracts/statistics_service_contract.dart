abstract class StatisticsServiceContract {
  Future<List<Map<String, dynamic>>> getTemperatureData(String machineId);
  Future<List<Map<String, dynamic>>> getMoistureData(String machineId);
  Future<List<Map<String, dynamic>>> getOxygenData(String machineId);
}