import '../entities/plan.dart';

abstract class PlanRepository {
  Future<List<PlannedWorkout>> getWeekPlan(DateTime weekStart);
  Future<PlannedWorkout> addPlannedWorkout(PlannedWorkout workout);
  Future<void> deletePlannedWorkout(String id);
  Future<PlannedWorkout> markCompleted(String id);
  Future<PlannedWorkout?> getTodayRecommendation({ReadinessData? readiness});
}

class ReadinessData {
  final int fatigue;
  final int soreness;
  final int sleepQuality;
  final int? heartRate;

  const ReadinessData({
    required this.fatigue,
    required this.soreness,
    required this.sleepQuality,
    this.heartRate,
  });
}
