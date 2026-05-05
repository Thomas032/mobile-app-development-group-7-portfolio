class MacroTargets {
  const MacroTargets({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
  });

  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;

  MacroTargets copyWith({
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
  }) {
    return MacroTargets(
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
    );
  }

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      proteinGrams: (json['proteinGrams'] as num).toDouble(),
      carbsGrams: (json['carbsGrams'] as num).toDouble(),
      fatGrams: (json['fatGrams'] as num).toDouble(),
      fiberGrams: (json['fiberGrams'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MacroTargets &&
            runtimeType == other.runtimeType &&
            proteinGrams == other.proteinGrams &&
            carbsGrams == other.carbsGrams &&
            fatGrams == other.fatGrams &&
            fiberGrams == other.fiberGrams;
  }

  @override
  int get hashCode {
    return Object.hash(proteinGrams, carbsGrams, fatGrams, fiberGrams);
  }
}
