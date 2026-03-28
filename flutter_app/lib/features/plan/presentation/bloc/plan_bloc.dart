import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/plan_repository.dart';

// Events
abstract class PlanEvent {}

class PlanWeekLoaded extends PlanEvent {
  final DateTime weekStart;
  PlanWeekLoaded(this.weekStart);
}

class PlanWorkoutAdded extends PlanEvent {
  final PlannedWorkout workout;
  PlanWorkoutAdded(this.workout);
}

class PlanWorkoutDeleted extends PlanEvent {
  final String id;
  PlanWorkoutDeleted(this.id);
}

class PlanRecommendationRequested extends PlanEvent {
  final ReadinessData? readiness;
  PlanRecommendationRequested({this.readiness});
}

// States
abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {
  final List<PlannedWorkout> weekPlan;
  final DateTime weekStart;
  final PlannedWorkout? recommendation;
  PlanLoaded(this.weekPlan, this.weekStart, {this.recommendation});
}

class PlanError extends PlanState {
  final String message;
  PlanError(this.message);
}

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final PlanRepository _repo;

  PlanBloc(this._repo) : super(PlanInitial()) {
    on<PlanWeekLoaded>(_onLoad);
    on<PlanWorkoutAdded>(_onAdd);
    on<PlanWorkoutDeleted>(_onDelete);
    on<PlanRecommendationRequested>(_onRecommend);
  }

  DateTime _currentWeekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) {
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  Future<void> _onLoad(PlanWeekLoaded event, Emitter<PlanState> emit) async {
    emit(PlanLoading());
    _currentWeekStart = _mondayOf(event.weekStart);
    final plan = await _repo.getWeekPlan(_currentWeekStart);
    final rec = await _repo.getTodayRecommendation();
    emit(PlanLoaded(plan, _currentWeekStart, recommendation: rec));
  }

  Future<void> _onAdd(PlanWorkoutAdded event, Emitter<PlanState> emit) async {
    await _repo.addPlannedWorkout(event.workout);
    final plan = await _repo.getWeekPlan(_currentWeekStart);
    final current = state;
    final rec = current is PlanLoaded ? current.recommendation : null;
    emit(PlanLoaded(plan, _currentWeekStart, recommendation: rec));
  }

  Future<void> _onDelete(PlanWorkoutDeleted event, Emitter<PlanState> emit) async {
    await _repo.deletePlannedWorkout(event.id);
    final plan = await _repo.getWeekPlan(_currentWeekStart);
    final current = state;
    final rec = current is PlanLoaded ? current.recommendation : null;
    emit(PlanLoaded(plan, _currentWeekStart, recommendation: rec));
  }

  Future<void> _onRecommend(PlanRecommendationRequested event, Emitter<PlanState> emit) async {
    final current = state;
    if (current is PlanLoaded) {
      final rec = await _repo.getTodayRecommendation(readiness: event.readiness);
      emit(PlanLoaded(current.weekPlan, current.weekStart, recommendation: rec));
    }
  }
}
