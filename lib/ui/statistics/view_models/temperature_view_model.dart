import 'package:flutter/foundation.dart';
import '../../../data/repositories/contracts/statistics_repository_contract.dart';

class TemperatureViewModel extends ChangeNotifier {
  final StatisticsRepository _repository;
  final String machineId;

  TemperatureViewModel({
    required StatisticsRepository repository,
    required this.machineId,
  }) : _repository = repository;

  double _currentTemperature = 0;
  List<double> _hourlyReadings = [];
  DateTime? _lastUpdated;
  bool _isLoading = false;
  String? _errorMessage;

  double get currentTemperature => _currentTemperature;
  List<double> get hourlyReadings => _hourlyReadings;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final readings = await _repository.getTemperatureReadings(machineId);

      if (readings.isNotEmpty) {
        _hourlyReadings = readings.map((r) => r.value).toList();
        _currentTemperature = readings.last.value;
        _lastUpdated = readings.last.timestamp;
      } else {
        _hourlyReadings = [];
        _currentTemperature = 0;
        _lastUpdated = null;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading temperature data: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}