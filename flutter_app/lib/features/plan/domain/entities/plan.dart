class PlannedWorkout {
  final String id;
  final String name;
  final DateTime scheduledDate;
  final List<String> exerciseNames;
  final String? recommendationReason;
  final String? intensityLabel;
  final String? intensityReasonShort;
  final bool completed;

  const PlannedWorkout({
    required this.id,
    required this.name,
    required this.scheduledDate,
    required this.exerciseNames,
    this.recommendationReason,
    this.intensityLabel,
    this.intensityReasonShort,
    this.completed = false,
  });

  PlannedWorkout copyWith({
    String? id,
    String? name,
    DateTime? scheduledDate,
    List<String>? exerciseNames,
    String? recommendationReason,
    String? intensityLabel,
    String? intensityReasonShort,
    bool? completed,
  }) {
    return PlannedWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      exerciseNames: exerciseNames ?? this.exerciseNames,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      intensityLabel: intensityLabel ?? this.intensityLabel,
      intensityReasonShort: intensityReasonShort ?? this.intensityReasonShort,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduledDate': scheduledDate.toIso8601String(),
        'exerciseNames': exerciseNames,
        'recommendationReason': recommendationReason,
        'intensityLabel': intensityLabel,
        'intensityReasonShort': intensityReasonShort,
        'completed': completed,
      };

  factory PlannedWorkout.fromJson(Map<String, dynamic> j) => PlannedWorkout(
        id: j['id'],
        name: j['name'],
        scheduledDate: DateTime.parse(j['scheduledDate']),
        exerciseNames: List<String>.from(j['exerciseNames'] ?? []),
        recommendationReason: j['recommendationReason'],
        intensityLabel: j['intensityLabel'],
        intensityReasonShort: j['intensityReasonShort'],
        completed: j['completed'] ?? false,
      );
}
