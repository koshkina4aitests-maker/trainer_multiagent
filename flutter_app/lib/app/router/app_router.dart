import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';
import '../../features/onboarding/presentation/pages/goal_selection_page.dart';
import '../../features/onboarding/presentation/pages/personal_metrics_page.dart';
import '../../features/onboarding/presentation/pages/health_limits_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/plan/domain/entities/plan.dart';
import '../../features/plan/presentation/bloc/plan_bloc.dart';
import '../../features/plan/presentation/pages/plan_page.dart';
import '../../features/plan/presentation/pages/workout_details_page.dart';
import '../../features/workout/presentation/bloc/workout_bloc.dart';
import '../../features/workout/presentation/bloc/workout_event.dart';
import '../../features/workout/presentation/pages/active_workout_page.dart';
import '../../features/workout/presentation/pages/post_workout_summary_page.dart';
import '../../features/progress/presentation/cubit/progress_cubit.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/exercises/presentation/cubit/exercise_cubit.dart';
import '../../features/exercises/presentation/pages/exercise_library_page.dart';
import '../../features/exercises/presentation/pages/add_exercise_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final storage = sl<LocalStorage>();
      final hasToken = storage.authToken != null;
      final onboardingDone = storage.isOnboardingDone;

      final location = state.matchedLocation;
      final isAuth = location.startsWith('/welcome') || location.startsWith('/sign-in');
      final isOnboarding = location.startsWith('/onboarding');

      if (!hasToken && !isAuth) return '/welcome';
      if (hasToken && !onboardingDone && !isOnboarding) return '/onboarding/goals';
      if (hasToken && onboardingDone && isAuth) return '/home';
      if (location == '/') return hasToken ? '/home' : '/welcome';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox.shrink()),
      GoRoute(
        path: '/welcome',
        builder: (context, _) => BlocProvider.value(
          value: authBloc,
          child: const WelcomePage(),
        ),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, _) => BlocProvider.value(
          value: authBloc,
          child: const SignInPage(),
        ),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<OnboardingCubit>(),
          child: const GoalSelectionPage(),
        ),
      ),
      GoRoute(
        path: '/onboarding/metrics',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<OnboardingCubit>(),
          child: const PersonalMetricsPage(),
        ),
      ),
      GoRoute(
        path: '/onboarding/health',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<OnboardingCubit>(),
          child: const HealthLimitsPage(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: authBloc),
              BlocProvider(create: (_) => sl<PlanBloc>()),
              BlocProvider(create: (_) => sl<WorkoutBloc>()),
              BlocProvider(create: (_) => sl<ProgressCubit>()),
              BlocProvider(create: (_) => sl<ProfileCubit>()),
              BlocProvider(create: (_) => sl<ExerciseCubit>()),
            ],
            child: _AppShell(child: child, state: state),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/home/plan',
            builder: (_, __) => const PlanPage(),
          ),
          GoRoute(
            path: '/home/plan/:workoutId',
            builder: (context, state) {
              final workout = state.extra as PlannedWorkout?;
              if (workout == null) {
                return const Scaffold(body: Center(child: Text('Тренировка не найдена')));
              }
              return WorkoutDetailsPage(workout: workout);
            },
          ),
          GoRoute(
            path: '/home/workouts',
            builder: (_, __) => const ExerciseLibraryPage(),
          ),
          GoRoute(
            path: '/home/workouts/add',
            builder: (_, __) => const AddExercisePage(),
          ),
          GoRoute(
            path: '/home/progress',
            builder: (_, __) => const ProgressPage(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/workout/active',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, _) => BlocProvider(
          create: (_) => sl<WorkoutBloc>()..add(WorkoutDraftRestored()),
          child: const ActiveWorkoutPage(),
        ),
      ),
      GoRoute(
        path: '/workout/summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, _) => BlocProvider(
          create: (_) => sl<WorkoutBloc>()..add(WorkoutDraftRestored()),
          child: const PostWorkoutSummaryPage(),
        ),
      ),
    ],
  );
}

class _AppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const _AppShell({required this.child, required this.state});

  int _tabIndex(String location) {
    if (location.startsWith('/home/plan')) return 1;
    if (location.startsWith('/home/workouts')) return 2;
    if (location.startsWith('/home/progress')) return 3;
    if (location.startsWith('/home/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = state.matchedLocation;
    final idx = _tabIndex(location);

    void onDestination(int i) {
      switch (i) {
        case 0: context.go('/home');
        case 1: context.go('/home/plan');
        case 2: context.go('/home/workouts');
        case 3: context.go('/home/progress');
        case 4: context.go('/home/profile');
      }
    }

    final isWide = MediaQuery.of(context).size.width >= 1024;
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: idx,
              onDestinationSelected: onDestination,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.white,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Главная'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text('План'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: Text('Упражнения'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Прогресс'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Профиль'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: onDestination,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'План'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Упражнения'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
