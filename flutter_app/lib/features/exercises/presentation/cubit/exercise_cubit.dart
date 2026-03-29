import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';

abstract class ExerciseState {}
class ExerciseInitial extends ExerciseState {}
class ExerciseLoading extends ExerciseState {}
class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final String query;
  final String? muscleGroup;
  ExerciseLoaded(this.exercises, {this.query = '', this.muscleGroup});
}
class ExerciseError extends ExerciseState {
  final String message;
  ExerciseError(this.message);
}

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository _repo;
  ExerciseCubit(this._repo) : super(ExerciseInitial());

  Future<void> load({String query = '', String? muscleGroup}) async {
    emit(ExerciseLoading());
    try {
      final list = await _repo.search(query, muscleGroup: muscleGroup);
      emit(ExerciseLoaded(list, query: query, muscleGroup: muscleGroup));
    } catch (e) {
      emit(ExerciseError(e.toString()));
    }
  }

  Future<void> add(Exercise exercise) async {
    await _repo.add(exercise);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }
}
