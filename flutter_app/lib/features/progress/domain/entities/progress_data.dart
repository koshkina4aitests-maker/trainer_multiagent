class WeeklyVolume {
  final DateTime weekStart;
  final double totalVolume;
  final int sessionsCount;

  const WeeklyVolume({
    required this.weekStart,
    required this.totalVolume,
    required this.sessionsCount,
  });
}

class PersonalRecord {
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.achievedAt,
  });
}

class ProgressSummary {
  final int totalSessions;
  final double totalVolume;
  final Duration totalDuration;
  final List<WeeklyVolume> weeklyVolumes;
  final List<PersonalRecord> personalRecords;
  final int currentStreak;

  const ProgressSummary({
    required this.totalSessions,
    required this.totalVolume,
    required this.totalDuration,
    required this.weeklyVolumes,
    required this.personalRecords,
    required this.currentStreak,
  });
}
