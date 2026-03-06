// lib/data/models/substrate_preset.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SubstrateMaterial {
  final String label;
  final bool isNitrogenRich;

  const SubstrateMaterial({
    required this.label,
    required this.isNitrogenRich,
  });

  factory SubstrateMaterial.fromJson(Map<String, dynamic> json) {
    return SubstrateMaterial(
      label: json['label'] as String,
      isNitrogenRich: json['isNitrogenRich'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'isNitrogenRich': isNitrogenRich,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubstrateMaterial &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}

class SubstratePreset {
  final String id;
  final String name;
  final List<SubstrateMaterial> materials;
  final String icon;
  final String? teamId;
  final String? createdBy;
  final DateTime? createdAt;
  final bool isDefault;

  const SubstratePreset({
    required this.id,
    required this.name,
    required this.materials,
    this.icon = 'usual_mix',
    this.teamId,
    this.createdBy,
    this.createdAt,
    this.isDefault = false,
  });

  int get greensCount => materials.where((m) => m.isNitrogenRich).length;
  int get brownsCount => materials.where((m) => !m.isNitrogenRich).length;

  factory SubstratePreset.fromJson(Map<String, dynamic> json, String docId) {
    return SubstratePreset(
      id: docId,
      name: json['name'] as String? ?? 'Unnamed Preset',
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => SubstrateMaterial.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      icon: json['icon'] as String? ?? 'usual_mix',
      teamId: json['teamId'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id is document ID
      'name': name,
      'materials': materials.map((m) => m.toJson()).toList(),
      'icon': icon,
      'teamId': teamId,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isDefault': isDefault,
    };
  }

  SubstratePreset copyWith({
    String? name,
    List<SubstrateMaterial>? materials,
    String? icon,
    String? teamId,
    String? createdBy,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return SubstratePreset(
      id: id,
      name: name ?? this.name,
      materials: materials ?? this.materials,
      icon: icon ?? this.icon,
      teamId: teamId ?? this.teamId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
