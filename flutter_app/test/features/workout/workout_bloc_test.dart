import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/domain/usecases/start_workout.dart';
import 'package:fitness_app/features/workout/domain/usecases/log_set.dart';
import 'package:fitness_app/features/workout/domain/usecases/complete_workout.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_state.dart';

class MockStartWorkout extends Mock implements StartWorkout {}
class MockLogSet extends Mock implements LogSet {}
class MockCompleteWorkout extends Mock implements CompleteWorkout {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late MockStartWorkout mockStart;
  late MockLogSet mockLogSet;
  late MockCompleteWorkout mockComplete;
  late MockWorkoutRepository mockRepo;

  setUp(() {
    mockStart = MockStartWorkout();
    mockLogSet = MockLogSet();
    mockComplete = MockCompleteWorkout();
    mockRepo = MockWorkoutRepository();
  });

  final testSession = WorkoutSession(
    id: 'session-1',
    name: 'Test Workout',
    startedAt: DateTime.now(),
    status: WorkoutStatus.inProgress,
    exercises: [],
  );

  final completedSession = testSession.copyWith(
    status: WorkoutStatus.completed,
    completedAt: DateTime.now(),
  );

  group('WorkoutBloc', () {
    blocTest<WorkoutBloc, WorkoutState>(
      'emits [WorkoutLoading, WorkoutInProgress] on start',
      build: () {
        when(() => mockStart(any(), any(), any()))
            .thenAnswer((_) async => testSession);
        when(() => mockRepo.getDraftSession()).thenAnswer((_) async => null);
        return WorkoutBloc(mockStart, mockLogSet, mockComplete, mockRepo);
      },
      act: (bloc) =>
          bloc.add(WorkoutStartRequested('Test', [], [])),
      expect: () =>
          [isA<WorkoutLoading>(), isA<WorkoutInProgress>()],
    );

    blocTest<WorkoutBloc, WorkoutState>(
      'emits [WorkoutLoading, WorkoutFinished] on complete',
      build: () {
        when(() => mockComplete(any(), notes: any(named: 'notes')))
            .thenAnswer((_) async => completedSession);
        when(() => mockRepo.getDraftSession()).thenAnswer((_) async => null);
        return WorkoutBloc(mockStart, mockLogSet, mockComplete, mockRepo);
      },
      seed: () => WorkoutInProgress(testSession),
      act: (bloc) => bloc.add(WorkoutCompleted()),
      expect: () =>
          [isA<WorkoutLoading>(), isA<WorkoutFinished>()],
    );
  });
}
