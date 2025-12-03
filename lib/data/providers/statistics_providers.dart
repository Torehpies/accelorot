import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/temperature_model.dart';
import '../models/moisture_model.dart';
import '../models/oxygen_model.dart';
import '../services/firebase/firebase_statistics_service.dart';
import '../services/contracts/statistics_service.dart';
import '../repositories/statistics_repository_remote.dart';
import '../repositories/contracts/statistics_repository.dart';

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Statistics Service provider
final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseStatisticsService(firestore: firestore);
});

// Statistics Repository provider
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return StatisticsRepositoryRemote (statisticsService: service);
});

// Temperature data provider
final temperatureDataProvider = FutureProvider.family<List<TemperatureModel>, String>((ref, machineId) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getTemperatureReadings(machineId);
});

// Moisture data provider
final moistureDataProvider = FutureProvider.family<List<MoistureModel>, String>((ref, machineId) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getMoistureReadings(machineId);
});

// Oxygen data provider
final oxygenDataProvider = FutureProvider.family<List<OxygenModel>, String>((ref, machineId) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getOxygenReadings(machineId);
});
