// lib/data/repositories/substrate_repository.dart

import '../models/substrate.dart';
import '../models/substrate_preset.dart';
import '../services/contracts/substrate_service.dart';

/// Repository for substrate-related operations
class SubstrateRepository {
  final SubstrateService _service;

  SubstrateRepository(this._service);

  /// Add new substrate entry
  Future<void> addSubstrate(CreateSubstrateRequest request) async {
    await _service.addSubstrate(request.toFirestore());
  }

  /// Get substrates for current team
  Future<List<Substrate>> getAllSubstrates() async {
    return await _service.fetchTeamSubstrates();
  }

  /// Get a single substrate by ID
  Future<Substrate?> getSubstrate(String id) async {
    return await _service.fetchSubstrateById(id);
  }

  /// Stream substrates for a batch
  Stream<List<Substrate>> streamSubstratesForBatch(String batchId) {
    return _service.streamSubstratesForBatch(batchId);
  }

  // ===== PRESET OPERATIONS =====

  Stream<List<SubstratePreset>> streamTeamPresets() {
    return _service.streamTeamPresets();
  }

  Future<void> savePreset(SubstratePreset preset) async {
    await _service.savePreset(preset);
  }

  Future<void> deletePreset(String presetId) async {
    await _service.deletePreset(presetId);
  }

  // ===== CUSTOM MATERIALS OPERATIONS =====

  Stream<List<SubstrateMaterial>> streamTeamCustomMaterials() {
    return _service.streamTeamCustomMaterials();
  }

  Future<void> saveCustomMaterial(SubstrateMaterial material) async {
    await _service.saveCustomMaterial(material);
  }

  // ===== CUSTOM ADDITIVES OPERATIONS =====

  Stream<List<String>> streamTeamCustomAdditives() {
    return _service.streamTeamCustomAdditives();
  }

  Future<void> saveCustomAdditive(String additive) async {
    await _service.saveCustomAdditive(additive);
  }
}
