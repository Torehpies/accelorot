import 'package:flutter/foundation.dart';
import '../../../data/repositories/contracts/statistics_repository_contract.dart';

class OxygenViewModel extends ChangeNotifier {
  final StatisticsRepositoryContract _repository;
  final String machineId;

  OxygenViewModel({
    required StatisticsRepositoryContract repository,
    required this.machineId,
  }) : _repository = repository;

  double _currentOxygen = 0;
  List<double> _hourlyReadings = [];
  DateTime? _lastUpdated;
  bool _isLoading = false;
  String? _errorMessage;

  double get currentOxygen => _currentOxygen;
  List<double> get hourlyReadings => _hourlyReadings;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final readings = await _repository.getOxygenReadings(machineId);

      if (readings.isNotEmpty) {
        _hourlyReadings = readings.map((r) => r.value).toList();
        _currentOxygen = readings.last.value;
        _lastUpdated = readings.last.timestamp;
      } else {
        _hourlyReadings = [];
        _currentOxygen = 0;
        _lastUpdated = null;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading oxygen data: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}