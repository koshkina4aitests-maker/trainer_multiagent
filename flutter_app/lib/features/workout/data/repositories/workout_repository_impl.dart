import 'package:uuid/uuid.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../../../../core/storage/local_storage.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDatasource _local;
  // ignore: unused_field
  final LocalStorage _storage;
  final _uuid = const Uuid();

  WorkoutRepositoryImpl(this._local, this._storage);

  @override
  Future<WorkoutSession> startSession(
      String name, List<String> exerciseIds, List<String> exerciseNames) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      name: name,
      startedAt: DateTime.now(),
      status: WorkoutStatus.inProgress,
      exercises: List.generate(
        exerciseIds.length,
        (i) => ExerciseLog(
          exerciseId: exerciseIds[i],
          exerciseName: exerciseNames[i],
          sets: [],
        ),
      ),
    );
    await _local.saveDraft(session);
    return session;
  }

  @override
  Future<WorkoutSession> logSet(
      String sessionId, String exerciseId, String exerciseName, SetLog setLog) async {
    final draft = await _local.getDraft();
    if (draft == null || draft.id != sessionId) {
      throw Exception('Сессия не найдена');
    }
    final exerciseIdx = draft.exercises.indexWhere((e) => e.exerciseId == exerciseId);
    List<ExerciseLog> updatedExercises;
    if (exerciseIdx >= 0) {
      updatedExercises = List.from(draft.exercises);
      updatedExercises[exerciseIdx] = draft.exercises[exerciseIdx].addSet(setLog);
    } else {
      updatedExercises = [
        ...draft.exercises,
        ExerciseLog(exerciseId: exerciseId, exerciseName: exerciseName, sets: [setLog]),
      ];
    }
    final updated = draft.copyWith(exercises: updatedExercises);
    await _local.saveDraft(updated);
    return updated;
  }

  @override
  Future<WorkoutSession> completeSession(String sessionId, {String? notes}) async {
    final draft = await _local.getDraft();
    if (draft == null || draft.id != sessionId) {
      throw Exception('Сессия не найдена');
    }
    final completed = draft.copyWith(
      status: WorkoutStatus.completed,
      completedAt: DateTime.now(),
      notes: notes,
    );
    await _local.saveToHistory(completed);
    await _local.clearDraft();
    return completed;
  }

  @override
  Future<List<WorkoutSession>> getHistory() => _local.getHistory();

  @override
  Future<WorkoutSession?> getDraftSession() => _local.getDraft();

  @override
  Future<void> saveDraft(WorkoutSession session) => _local.saveDraft(session);

  @override
  Future<void> clearDraft() => _local.clearDraft();
}
