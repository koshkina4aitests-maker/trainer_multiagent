import '../../domain/entities/progress_data.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDatasource _local;
  ProgressRepositoryImpl(this._local);

  @override
  Future<ProgressSummary> getSummary({int days = 30}) async {
    final all = await _local.getHistory();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = all.where((s) => s.startedAt.isAfter(cutoff)).toList();

    final totalVolume = filtered.fold<double>(0, (sum, s) => sum + s.totalVolume);
    final totalDuration = filtered.fold<Duration>(
        Duration.zero, (sum, s) => sum + s.duration);

    // Group by week
    final weekMap = <DateTime, WeeklyVolume>{};
    for (final session in filtered) {
      final monday = _monday(session.startedAt);
      final existing = weekMap[monday];
      if (existing != null) {
        weekMap[monday] = WeeklyVolume(
          weekStart: monday,
          totalVolume: existing.totalVolume + session.totalVolume,
          sessionsCount: existing.sessionsCount + 1,
        );
      } else {
        weekMap[monday] = WeeklyVolume(
          weekStart: monday,
          totalVolume: session.totalVolume,
          sessionsCount: 1,
        );
      }
    }
    final weeklyVolumes = weekMap.values.toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

    // Personal Records per exercise
    final prMap = <String, PersonalRecord>{};
    for (final session in all) {
      for (final exLog in session.exercises) {
        for (final set in exLog.sets) {
          final key = exLog.exerciseName;
          final existing = prMap[key];
          if (existing == null || set.weight > existing.weight ||
              (set.weight == existing.weight && set.reps > existing.reps)) {
            prMap[key] = PersonalRecord(
              exerciseName: exLog.exerciseName,
              weight: set.weight,
              reps: set.reps,
              achievedAt: session.startedAt,
            );
          }
        }
      }
    }

    // Streak (consecutive days with workout)
    int streak = 0;
    if (all.isNotEmpty) {
      DateTime day = DateTime.now();
      final sessionDays = all.map((s) =>
          DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day)).toSet();
      while (sessionDays.contains(DateTime(day.year, day.month, day.day))) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      }
    }

    return ProgressSummary(
      totalSessions: filtered.length,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      weeklyVolumes: weeklyVolumes,
      personalRecords: prMap.values.toList(),
      currentStreak: streak,
    );
  }

  DateTime _monday(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));
}
