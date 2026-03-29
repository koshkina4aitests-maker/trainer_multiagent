import '../../domain/entities/workout_session.dart';

abstract class WorkoutEvent {}

class WorkoutStartRequested extends WorkoutEvent {
  final String name;
  final List<String> exerciseIds;
  final List<String> exerciseNames;
  WorkoutStartRequested(this.name, this.exerciseIds, this.exerciseNames);
}

class WorkoutSetLogged extends WorkoutEvent {
  final String exerciseId;
  final String exerciseName;
  final SetLog setLog;
  WorkoutSetLogged(this.exerciseId, this.exerciseName, this.setLog);
}

class WorkoutCompleted extends WorkoutEvent {
  final String? notes;
  WorkoutCompleted({this.notes});
}

class WorkoutDraftRestored extends WorkoutEvent {}

class WorkoutHistoryLoaded extends WorkoutEvent {}
