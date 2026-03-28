import '../entities/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getAll();
  Future<Exercise> add(Exercise exercise);
  Future<void> delete(String id);
  Future<List<Exercise>> search(String query, {String? muscleGroup});
}
