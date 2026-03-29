import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class CompleteWorkout {
  final WorkoutRepository _repo;
  CompleteWorkout(this._repo);

  Future<WorkoutSession> call(String sessionId, {String? notes}) =>
      _repo.completeSession(sessionId, notes: notes);
}
