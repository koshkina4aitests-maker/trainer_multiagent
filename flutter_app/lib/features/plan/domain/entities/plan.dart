enum RecommendationStyle { fullbody, splitUpper, splitLower }

extension RecommendationStyleX on RecommendationStyle {
  String get label {
    switch (this) {
      case RecommendationStyle.fullbody:
        return 'fullbody';
      case RecommendationStyle.splitUpper:
        return 'split upper';
      case RecommendationStyle.splitLower:
        return 'split lower';
    }
  }
}

class PlannedExerciseDetail {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weightKg;
  final int rir;

  const PlannedExerciseDetail({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.rir,
  });

  PlannedExerciseDetail copyWith({
    String? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weightKg,
    int? rir,
  }) {
    return PlannedExerciseDetail(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      rir: rir ?? this.rir,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'rir': rir,
      };

  factory PlannedExerciseDetail.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseDetail(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 20,
      rir: json['rir'] ?? 2,
    );
  }
}

class PlannedWorkout {
  final String id;
  final String name;
  final DateTime scheduledDate;
  final RecommendationStyle style;
  final List<String> exerciseNames;
  final List<PlannedExerciseDetail> exerciseDetails;
  final String? recommendationReason;
  final String? intensityLabel;
  final String? intensityReasonShort;
  final bool completed;

  const PlannedWorkout({
    required this.id,
    required this.name,
    required this.scheduledDate,
    this.style = RecommendationStyle.fullbody,
    this.exerciseNames = const [],
    this.exerciseDetails = const [],
    this.recommendationReason,
    this.intensityLabel,
    this.intensityReasonShort,
    this.completed = false,
  });

  List<PlannedExerciseDetail> get normalizedDetails {
    if (exerciseDetails.isNotEmpty) return exerciseDetails;
    return exerciseNames
        .map(
          (name) => PlannedExerciseDetail(
            exerciseId: name,
            exerciseName: name,
            sets: 3,
            reps: 10,
            weightKg: 20,
            rir: 2,
          ),
        )
        .toList();
  }

  PlannedWorkout copyWith({
    String? id,
    String? name,
    DateTime? scheduledDate,
    RecommendationStyle? style,
    List<String>? exerciseNames,
    List<PlannedExerciseDetail>? exerciseDetails,
    String? recommendationReason,
    String? intensityLabel,
    String? intensityReasonShort,
    bool? completed,
  }) {
    return PlannedWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      style: style ?? this.style,
      exerciseNames: exerciseNames ?? this.exerciseNames,
      exerciseDetails: exerciseDetails ?? this.exerciseDetails,
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
        'style': style.name,
        'exerciseNames': exerciseNames.isNotEmpty
            ? exerciseNames
            : normalizedDetails.map((e) => e.exerciseName).toList(),
        'exerciseDetails': normalizedDetails.map((e) => e.toJson()).toList(),
        'recommendationReason': recommendationReason,
        'intensityLabel': intensityLabel,
        'intensityReasonShort': intensityReasonShort,
        'completed': completed,
      };

  factory PlannedWorkout.fromJson(Map<String, dynamic> j) {
    final details = ((j['exerciseDetails'] ?? []) as List)
        .map((e) => PlannedExerciseDetail.fromJson(e))
        .toList();
    final names = List<String>.from(j['exerciseNames'] ?? []);
    final styleName = j['style'] as String?;
    final style = RecommendationStyle.values.firstWhere(
      (s) => s.name == styleName,
      orElse: () => RecommendationStyle.fullbody,
    );
    return PlannedWorkout(
      id: j['id'],
      name: j['name'],
      scheduledDate: DateTime.parse(j['scheduledDate']),
      style: style,
      exerciseNames:
          names.isNotEmpty ? names : details.map((e) => e.exerciseName).toList(),
      exerciseDetails: details,
      recommendationReason: j['recommendationReason'],
      intensityLabel: j['intensityLabel'],
      intensityReasonShort: j['intensityReasonShort'],
      completed: j['completed'] ?? false,
    );
  }
}
