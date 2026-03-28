import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class StartWorkout {
  final WorkoutRepository _repo;
  StartWorkout(this._repo);

  Future<WorkoutSession> call(String name, List<String> exerciseIds, List<String> exerciseNames) =>
      _repo.startSession(name, exerciseIds, exerciseNames);
}
