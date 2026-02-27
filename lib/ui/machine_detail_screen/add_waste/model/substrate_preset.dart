// No material import needed

class SubstrateMaterial {
  final String label;
  final bool isNitrogenRich;

  const SubstrateMaterial({
    required this.label,
    required this.isNitrogenRich,
  });

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
  final String icon; // Icon name/string

  const SubstratePreset({
    required this.id,
    required this.name,
    required this.materials,
    this.icon = 'usual_mix',
  });

  int get greensCount => materials.where((m) => m.isNitrogenRich).length;
  int get brownsCount => materials.where((m) => !m.isNitrogenRich).length;

  SubstratePreset copyWith({
    String? name,
    List<SubstrateMaterial>? materials,
    String? icon,
  }) {
    return SubstratePreset(
      id: id,
      name: name ?? this.name,
      materials: materials ?? this.materials,
      icon: icon ?? this.icon,
    );
  }
}
