import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';
import '../../features/exercises/data/datasources/exercise_local_datasource.dart';
import '../../features/exercises/data/repositories/exercise_repository_impl.dart';
import '../../features/exercises/domain/repositories/exercise_repository.dart';
import '../../features/exercises/presentation/cubit/exercise_cubit.dart';
import '../../features/workout/data/datasources/workout_local_datasource.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/workout/domain/usecases/start_workout.dart';
import '../../features/workout/domain/usecases/log_set.dart';
import '../../features/workout/domain/usecases/complete_workout.dart';
import '../../features/workout/presentation/bloc/workout_bloc.dart';
import '../../features/plan/data/datasources/plan_local_datasource.dart';
import '../../features/plan/data/repositories/plan_repository_impl.dart';
import '../../features/plan/domain/repositories/plan_repository.dart';
import '../../features/plan/presentation/bloc/plan_bloc.dart';
import '../../features/progress/data/datasources/progress_local_datasource.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/progress/presentation/cubit/progress_cubit.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<LocalStorage>(LocalStorage(prefs));

  // Auth
  sl.registerLazySingleton<AuthLocalDatasource>(() => AuthLocalDatasource(sl()));
  sl.registerLazySingleton<GoogleSignIn>(() {
    final webClientId = const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (webClientId.isNotEmpty) {
      return GoogleSignIn(
        scopes: const ['email', 'profile', 'openid'],
        serverClientId: webClientId,
      );
    }
    return GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
    );
  });
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasource(client: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl(), sl()));

  // Onboarding
  sl.registerFactory<OnboardingCubit>(() => OnboardingCubit(sl()));

  // Exercises
  sl.registerLazySingleton<ExerciseLocalDatasource>(() => ExerciseLocalDatasource(sl()));
  sl.registerLazySingleton<ExerciseRepository>(() => ExerciseRepositoryImpl(sl()));
  sl.registerFactory<ExerciseCubit>(() => ExerciseCubit(sl()));

  // Workout
  sl.registerLazySingleton<WorkoutLocalDatasource>(() => WorkoutLocalDatasource(sl()));
  sl.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<StartWorkout>(() => StartWorkout(sl()));
  sl.registerLazySingleton<LogSet>(() => LogSet(sl()));
  sl.registerLazySingleton<CompleteWorkout>(() => CompleteWorkout(sl()));
  sl.registerFactory<WorkoutBloc>(() => WorkoutBloc(sl(), sl(), sl(), sl()));

  // Plan
  sl.registerLazySingleton<PlanLocalDatasource>(() => PlanLocalDatasource(sl()));
  sl.registerLazySingleton<PlanRepository>(() => PlanRepositoryImpl(sl(), sl()));
  sl.registerFactory<PlanBloc>(() => PlanBloc(sl()));

  // Progress
  sl.registerLazySingleton<ProgressLocalDatasource>(() => ProgressLocalDatasource(sl()));
  sl.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl(sl()));
  sl.registerFactory<ProgressCubit>(() => ProgressCubit(sl()));

  // Profile
  sl.registerLazySingleton<ProfileLocalDatasource>(() => ProfileLocalDatasource(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl()));
}
