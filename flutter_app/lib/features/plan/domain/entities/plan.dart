class PlannedWorkout {
  final String id;
  final String name;
  final DateTime scheduledDate;
  final List<String> exerciseNames;
  final String? recommendationReason;
  final bool completed;

  const PlannedWorkout({
    required this.id,
    required this.name,
    required this.scheduledDate,
    required this.exerciseNames,
    this.recommendationReason,
    this.completed = false,
  });

  PlannedWorkout copyWith({
    String? id,
    String? name,
    DateTime? scheduledDate,
    List<String>? exerciseNames,
    String? recommendationReason,
    bool? completed,
  }) {
    return PlannedWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      exerciseNames: exerciseNames ?? this.exerciseNames,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduledDate': scheduledDate.toIso8601String(),
        'exerciseNames': exerciseNames,
        'recommendationReason': recommendationReason,
        'completed': completed,
      };

  factory PlannedWorkout.fromJson(Map<String, dynamic> j) => PlannedWorkout(
        id: j['id'],
        name: j['name'],
        scheduledDate: DateTime.parse(j['scheduledDate']),
        exerciseNames: List<String>.from(j['exerciseNames'] ?? []),
        recommendationReason: j['recommendationReason'],
        completed: j['completed'] ?? false,
      );
}
