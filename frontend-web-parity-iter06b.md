# Frontend Web Parity Report — iter-06b

## Goal
Implement web frontend behavior parity with mobile for core flows while keeping the same domain rules and data semantics.

## Implemented

### 1) Adaptive app shell (navigation parity)
- file: `flutter_app/lib/app/router/app_router.dart`
- behavior:
  - mobile: existing `BottomNavigationBar`
  - wide screens (`>= 1024`): `NavigationRail` with the same sections/routes:
    - Главная
    - План
    - Упражнения
    - Прогресс
    - Профиль
- parity note: route mapping and state transitions are unchanged.

### 2) Home page responsive container
- file: `flutter_app/lib/features/home/presentation/pages/home_page.dart`
- behavior:
  - content is centered and constrained on wide screens (`maxWidth: 1100`)
  - existing recommendation/profile/quick-start flows unchanged
- parity note: recommendation style/preview/copy/start logic remains identical to mobile.

### 3) Plan page responsive container
- file: `flutter_app/lib/features/plan/presentation/pages/plan_page.dart`
- behavior:
  - page content centered and width-constrained on web (`maxWidth: 1100`)
  - plan creation/edit/search interactions preserved
- parity note: same validation rules and save behavior as mobile.

### 4) Profile page responsive container
- file: `flutter_app/lib/features/profile/presentation/pages/profile_page.dart`
- behavior:
  - profile form centered with max width for desktop readability
  - same profile fields and persistence behavior
- parity note: name/training-style/goal/health-limits semantics unchanged.

### 5) Workout pages responsive containers
- files:
  - `flutter_app/lib/features/workout/presentation/pages/active_workout_page.dart`
  - `flutter_app/lib/features/workout/presentation/pages/post_workout_summary_page.dart`
- behavior:
  - active workout and summary content constrained/centered on wide screens
  - set logging, completion flow and summary actions unchanged
- parity note: workout lifecycle matches mobile behavior.

### 6) Test robustness (backend)
- file: `tests/test_api_flow.py`
- update:
  - idempotency keys are now unique per test run (`session-start`, `complete-session`, `recommendation`)
- reason:
  - remove flaky failures when tests run repeatedly against persistent local DB.

## Validation
- `flutter analyze` — passed
- `flutter test` — passed
- `python3 -m pytest -q` — passed

## Result
- Web frontend now has practical parity to mobile for core user flows with responsive desktop UX.
- Domain rules and API/data contracts are preserved across platforms.
