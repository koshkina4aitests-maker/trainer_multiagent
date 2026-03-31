import '../entities/workout_session.dart';

abstract class WorkoutRepository {
  Future<WorkoutSession> startSession(String name, List<String> exerciseIds, List<String> exerciseNames);
  Future<WorkoutSession> logSet(String sessionId, String exerciseId, String exerciseName, SetLog setLog);
  Future<WorkoutSession> completeSession(String sessionId, {String? notes});
  Future<List<WorkoutSession>> getHistory();
  Future<WorkoutSession?> getDraftSession();
  Future<void> saveDraft(WorkoutSession session);
  Future<void> clearDraft();
}
