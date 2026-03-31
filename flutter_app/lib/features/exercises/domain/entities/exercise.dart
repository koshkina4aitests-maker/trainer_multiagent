class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String equipment;
  final List<String> healthRestrictions;
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    this.healthRestrictions = const [],
    this.isCustom = false,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? muscleGroup,
    String? equipment,
    List<String>? healthRestrictions,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      healthRestrictions: healthRestrictions ?? this.healthRestrictions,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'muscleGroup': muscleGroup,
        'equipment': equipment,
        'healthRestrictions': healthRestrictions,
        'isCustom': isCustom,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        muscleGroup: json['muscleGroup'] ?? '',
        equipment: json['equipment'] ?? '',
        healthRestrictions: List<String>.from(json['healthRestrictions'] ?? []),
        isCustom: json['isCustom'] ?? false,
      );
}
