class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    this.imageUrl,
    this.sugarGrams = 0,
    this.sodiumMilligrams = 0,
    this.saturatedFatGrams = 0,
  });

  final String id;
  final String name;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final String? imageUrl;
  final double sugarGrams;
  final double sodiumMilligrams;
  final double saturatedFatGrams;

  FoodItem copyWith({
    String? id,
    String? name,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    String? imageUrl,
    double? sugarGrams,
    double? sodiumMilligrams,
    double? saturatedFatGrams,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      imageUrl: imageUrl ?? this.imageUrl,
      sugarGrams: sugarGrams ?? this.sugarGrams,
      sodiumMilligrams: sodiumMilligrams ?? this.sodiumMilligrams,
      saturatedFatGrams: saturatedFatGrams ?? this.saturatedFatGrams,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      proteinGrams: (json['proteinGrams'] as num).toDouble(),
      carbsGrams: (json['carbsGrams'] as num).toDouble(),
      fatGrams: (json['fatGrams'] as num).toDouble(),
      fiberGrams: (json['fiberGrams'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble() ?? 0,
      sodiumMilligrams: (json['sodiumMilligrams'] as num?)?.toDouble() ?? 0,
      saturatedFatGrams: (json['saturatedFatGrams'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'imageUrl': imageUrl,
      'sugarGrams': sugarGrams,
      'sodiumMilligrams': sodiumMilligrams,
      'saturatedFatGrams': saturatedFatGrams,
    };
  }
}
