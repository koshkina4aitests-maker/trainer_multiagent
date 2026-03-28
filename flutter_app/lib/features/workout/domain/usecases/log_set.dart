import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class LogSet {
  final WorkoutRepository _repo;
  LogSet(this._repo);

  Future<WorkoutSession> call(String sessionId, String exerciseId, String exerciseName, SetLog setLog) =>
      _repo.logSet(sessionId, exerciseId, exerciseName, setLog);
}
