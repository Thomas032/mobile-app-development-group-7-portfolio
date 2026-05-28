class BodyProgressEntry {
  const BodyProgressEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.waistCm,
    this.note,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double? waistCm;
  final String? note;

  BodyProgressEntry copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    double? waistCm,
    String? note,
  }) {
    return BodyProgressEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      note: note ?? this.note,
    );
  }

  factory BodyProgressEntry.fromJson(Map<String, dynamic> json) {
    return BodyProgressEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'note': note,
    };
  }
}
