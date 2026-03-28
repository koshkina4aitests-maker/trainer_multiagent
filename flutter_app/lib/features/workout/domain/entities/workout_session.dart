class SetLog {
  final int setNumber;
  final int reps;
  final double weight;
  final int rir;
  final DateTime timestamp;

  const SetLog({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.rir,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weight': weight,
        'rir': rir,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SetLog.fromJson(Map<String, dynamic> j) => SetLog(
        setNumber: j['setNumber'],
        reps: j['reps'],
        weight: (j['weight'] as num).toDouble(),
        rir: j['rir'],
        timestamp: DateTime.parse(j['timestamp']),
      );
}

class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final List<SetLog> sets;

  const ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  double get totalVolume => sets.fold(0, (sum, s) => sum + s.reps * s.weight);
  double get maxWeight => sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  ExerciseLog addSet(SetLog s) => ExerciseLog(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        sets: [...sets, s],
      );

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory ExerciseLog.fromJson(Map<String, dynamic> j) => ExerciseLog(
        exerciseId: j['exerciseId'],
        exerciseName: j['exerciseName'],
        sets: (j['sets'] as List).map((s) => SetLog.fromJson(s)).toList(),
      );
}

enum WorkoutStatus { planned, inProgress, completed, cancelled }

class WorkoutSession {
  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? completedAt;
  final WorkoutStatus status;
  final List<ExerciseLog> exercises;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.exercises,
    this.notes,
  });

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);
  Duration get duration => (completedAt ?? DateTime.now()).difference(startedAt);

  WorkoutSession copyWith({
    String? id,
    String? name,
    DateTime? startedAt,
    DateTime? completedAt,
    WorkoutStatus? status,
    List<ExerciseLog>? exercises,
    String? notes,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
        id: j['id'],
        name: j['name'],
        startedAt: DateTime.parse(j['startedAt']),
        completedAt: j['completedAt'] != null ? DateTime.parse(j['completedAt']) : null,
        status: WorkoutStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => WorkoutStatus.completed),
        exercises: (j['exercises'] as List).map((e) => ExerciseLog.fromJson(e)).toList(),
        notes: j['notes'],
      );
}
