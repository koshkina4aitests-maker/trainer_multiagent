import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_local_datasource.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDatasource _local;
  ExerciseRepositoryImpl(this._local);

  @override
  Future<List<Exercise>> getAll() => _local.getAll();

  @override
  Future<Exercise> add(Exercise exercise) async {
    await _local.save(exercise);
    return exercise;
  }

  @override
  Future<void> delete(String id) => _local.delete(id);

  @override
  Future<List<Exercise>> search(String query, {String? muscleGroup}) async {
    final all = await _local.getAll();
    return all.where((e) {
      final matchQuery = query.isEmpty ||
          e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(query.toLowerCase());
      final matchGroup = muscleGroup == null || muscleGroup.isEmpty || e.muscleGroup == muscleGroup;
      return matchQuery && matchGroup;
    }).toList();
  }
}
