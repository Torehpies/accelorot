// lib/data/services/contracts/substrate_service.dart

import '../../models/substrate.dart';
import '../../models/substrate_preset.dart';

/// Abstract interface for substrate data operations
abstract class SubstrateService {
  /// Fetch all substrates for the current user's team
  /// Handles authentication and team resolution internally
  Future<List<Substrate>> fetchTeamSubstrates();

  /// Add a new substrate entry
  /// Handles authentication, batch creation/retrieval, and timestamp updates internally
  /// @param data - substrate data including machineId
  Future<void> addSubstrate(Map<String, dynamic> data);

  /// Fetch a single substrate by ID
  Future<Substrate?> fetchSubstrateById(String substrateId);

  /// Stream substrates for a specific batch
  Stream<List<Substrate>> streamSubstratesForBatch(String batchId);

  // ===== PRESET OPERATIONS =====

  /// Stream all substrate presets for the current user's team
  Stream<List<SubstratePreset>> streamTeamPresets();

  /// Save or update a substrate preset
  Future<void> savePreset(SubstratePreset preset);

  /// Delete a substrate preset by its ID
  Future<void> deletePreset(String presetId);

  // ===== CUSTOM MATERIALS OPERATIONS =====

  /// Stream all custom substrate materials for the current user's team
  Stream<List<SubstrateMaterial>> streamTeamCustomMaterials();

  /// Save a new custom substrate material to the team's collection
  Future<void> saveCustomMaterial(SubstrateMaterial material);

  // ===== CUSTOM ADDITIVES OPERATIONS =====

  /// Stream all custom additives for the current user's team
  Stream<List<String>> streamTeamCustomAdditives();

  /// Save a new custom additive to the team's collection
  Future<void> saveCustomAdditive(String additive);
}
