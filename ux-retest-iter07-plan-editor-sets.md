# UX Retest Report — iter-07 (planned recommendation editor)

## New requirements
1. Allow adding/removing exercises in workouts copied from recommendations.
2. Allow different set targets within one exercise (different reps/weight/RIR per set).

## Implemented
- file: `flutter_app/lib/features/plan/domain/entities/plan.dart`
  - added per-set model: `PlannedSetDetail`
  - `PlannedExerciseDetail` now supports:
    - `setDetails: List<PlannedSetDetail>`
    - `normalizedSetDetails` fallback generation from legacy fields (`sets/reps/weightKg/rir`)
  - serialization updated with backward-compatible fallback.

- file: `flutter_app/lib/features/plan/presentation/pages/workout_details_page.dart`
  - edit sheet now supports:
    - deleting exercises (`Удалить упражнение`)
    - adding exercises (`Добавить упражнение`)
    - editing exercise name in-place
    - editing set-by-set targets in dedicated block:
      - add/remove set rows
      - per row: reps / weight / RIR
  - save validation:
    - at least one exercise required
    - at least one non-empty exercise name required

## Verification
- `flutter analyze`: passed
- `flutter test`: passed

## UX verdict
- status: `passed`
- blockers: none
- note: recommended workouts can now be fully edited as plans, including variable set programming.
