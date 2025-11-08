import 'package:flutter/material.dart';
import '../../../../services/firestore_statistics_service.dart';
import '../widgets/oxygen_statistic_card.dart';

class OxygenStatsView extends StatefulWidget {
  final String? machineId;
  
  const OxygenStatsView({super.key, this.machineId});

  @override
  State<OxygenStatsView> createState() => _OxygenStatsViewState();
}

class _OxygenStatsViewState extends State<OxygenStatsView> {
  double _currentOxygen = 0;
  List<double> _hourlyReadings = [];
  DateTime? _lastUpdated;
  bool _isLoading = true;
  String? _errorMessage;

  static const String _defaultMachineId = "01";

  String get _machineId => widget.machineId ?? _defaultMachineId;

  @override
  void initState() {
    super.initState();
    _loadOxygenData();
  }

  @override
  void didUpdateWidget(OxygenStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machineId != widget.machineId) {
      _loadOxygenData();
    }
  }

  Future<void> _loadOxygenData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await FirestoreStatisticsService.getOxygenData(_machineId);

      if (data.isNotEmpty) {
        _hourlyReadings = data.map((e) => e['value'] as double).toList();
        _currentOxygen = _hourlyReadings.last;
        _lastUpdated = data.last['timestamp'];
      } else {
        _hourlyReadings = [];
        _currentOxygen = 0;
        _lastUpdated = null;
      }
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 24, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text(
                'Error loading data',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _loadOxygenData,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Retry', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return OxygenStatisticCard(
      currentOxygen: _currentOxygen,
      hourlyReadings: _hourlyReadings,
      lastUpdated: _lastUpdated,
    );
  }
}