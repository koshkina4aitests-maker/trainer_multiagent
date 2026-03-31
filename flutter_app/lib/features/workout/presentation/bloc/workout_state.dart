import '../../domain/entities/workout_session.dart';

abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutInProgress extends WorkoutState {
  final WorkoutSession session;
  WorkoutInProgress(this.session);
}

class WorkoutFinished extends WorkoutState {
  final WorkoutSession session;
  WorkoutFinished(this.session);
}

class WorkoutHistoryState extends WorkoutState {
  final List<WorkoutSession> sessions;
  WorkoutHistoryState(this.sessions);
}

class WorkoutError extends WorkoutState {
  final String message;
  WorkoutError(this.message);
}
