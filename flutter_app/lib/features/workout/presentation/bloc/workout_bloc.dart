import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/start_workout.dart';
import '../../domain/usecases/log_set.dart';
import '../../domain/usecases/complete_workout.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final StartWorkout _start;
  final LogSet _logSet;
  final CompleteWorkout _complete;
  final WorkoutRepository _repo;

  WorkoutBloc(this._start, this._logSet, this._complete, this._repo) : super(WorkoutInitial()) {
    on<WorkoutStartRequested>(_onStart);
    on<WorkoutSetLogged>(_onLogSet);
    on<WorkoutCompleted>(_onComplete);
    on<WorkoutDraftRestored>(_onRestoreDraft);
    on<WorkoutHistoryLoaded>(_onLoadHistory);
  }

  Future<void> _onStart(WorkoutStartRequested event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());
    try {
      final session = await _start(event.name, event.exerciseIds, event.exerciseNames);
      emit(WorkoutInProgress(session));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onLogSet(WorkoutSetLogged event, Emitter<WorkoutState> emit) async {
    final current = state;
    if (current is! WorkoutInProgress) return;
    try {
      final updated = await _logSet(
          current.session.id, event.exerciseId, event.exerciseName, event.setLog);
      emit(WorkoutInProgress(updated));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onComplete(WorkoutCompleted event, Emitter<WorkoutState> emit) async {
    final current = state;
    if (current is! WorkoutInProgress) return;
    emit(WorkoutLoading());
    try {
      final finished = await _complete(current.session.id, notes: event.notes);
      emit(WorkoutFinished(finished));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onRestoreDraft(WorkoutDraftRestored event, Emitter<WorkoutState> emit) async {
    final draft = await _repo.getDraftSession();
    if (draft != null) {
      emit(WorkoutInProgress(draft));
    } else {
      emit(WorkoutInitial());
    }
  }

  Future<void> _onLoadHistory(WorkoutHistoryLoaded event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());
    final sessions = await _repo.getHistory();
    emit(WorkoutHistoryState(sessions));
  }
}
