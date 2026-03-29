# UX Strict Audit Report — iter-06 (latest release)

## Scope and method
- artifact under review: `fitness_app-release-iter06.apk`
- approach: maximally strict heuristic audit (task-flow integrity, input validation behavior, error prevention/recovery, consistency, accessibility hints)
- evidence source: release flow behavior inferred from shipped UI/state code paths

## Verdict
- status: `failed_with_blockers`
- blocking findings: 4
- high/medium findings: 6
- recommendation: block production promotion until critical/high issues are fixed and re-tested

## Findings (ordered by severity)

### CRITICAL-01 — Recommendation "Start" opens empty workout instead of recommended exercises
- severity: `critical`
- impact: core recommendation flow is misleading; user expects planned exercise list, but receives free-form empty session
- evidence:
  - `flutter_app/lib/features/home/presentation/pages/home_page.dart:251-255` sends `WorkoutStartRequested(rec.name, [], rec.exerciseNames)`
  - `flutter_app/lib/features/workout/data/repositories/workout_repository_impl.dart:23-30` creates exercise list by `exerciseIds.length` only
- user-visible result:
  - recommendation card says exercises were selected, but active workout can open as "Свободная тренировка" with no planned exercise tabs
- expected behavior:
  - start workout should pass and render full recommended exercise structure (IDs + names)

### HIGH-01 — Saving edited workout closes two screens unexpectedly
- severity: `high`
- impact: disruptive navigation; user loses context after saving edit
- evidence:
  - `flutter_app/lib/features/plan/presentation/pages/workout_details_page.dart:424-425` calls `Navigator.of(context).pop()` twice
- user-visible result:
  - after save in edit sheet, app may close sheet *and* workout details page, returning user too far back
- expected behavior:
  - close only edit sheet and remain on updated details screen

### HIGH-02 — Recommendation card does not show sets/reps/weight/RIR
- severity: `high`
- impact: mismatch with iter-06 requirement and weak decision transparency
- evidence:
  - `flutter_app/lib/features/home/presentation/pages/home_page.dart:205-208` shows only name and short exercise name list
  - no detailed per-exercise prescription is rendered in recommendation card block
- expected behavior:
  - recommendation preview should include structured parameters (sets/reps/weight/RIR) before start/copy

### HIGH-03 — Silent failure on "Save workout" in plan creation
- severity: `high`
- impact: user clicks Save and sees no feedback; creates confusion and repeated actions
- evidence:
  - `flutter_app/lib/features/plan/presentation/pages/plan_page.dart:372-374` returns early for invalid state with no snackbar/error text
- expected behavior:
  - explicit inline validation or toast for missing title/exercises

### MEDIUM-01 — Profile weight/height invalid values are silently discarded
- severity: `medium`
- impact: perceived data loss; user may think data was saved while parsing fell back to null
- evidence:
  - fields have no validator: `flutter_app/lib/features/profile/presentation/pages/profile_page.dart:171-184`
  - save path uses `double.tryParse(... )` -> null: `:286-289`
- expected behavior:
  - visible validation messages for malformed values before save

### MEDIUM-02 — Plan persistence drops workout style/completed flags when saving
- severity: `medium`
- impact: inconsistent state restoration and weak continuity across screens
- evidence:
  - `flutter_app/lib/features/plan/data/repositories/plan_repository_impl.dart:27-36` reconstructs `PlannedWorkout` without forwarding `style` and `completed`
- expected behavior:
  - preserve all relevant fields from source workout during save/update

### MEDIUM-03 — Recommendation style labels are not localized consistently
- severity: `medium`
- impact: mixed RU/EN UI reduces clarity
- evidence:
  - `flutter_app/lib/features/plan/domain/entities/plan.dart:7-12` labels: `fullbody`, `split upper`, `split lower`
  - `flutter_app/lib/features/profile/presentation/pages/profile_page.dart:204` labels `Fullbody` / `Split`
- expected behavior:
  - fully localized human-readable labels for RU interface

### LOW-01 — Missing tooltip/semantics hints on key icon buttons
- severity: `low`
- impact: accessibility discoverability reduced (screen readers and long-press hints)
- evidence:
  - notification icon has no tooltip: `flutter_app/lib/features/home/presentation/pages/home_page.dart:60-63`
- expected behavior:
  - add tooltips/semantic labels for icon-only controls

## Additional testing risks
- audit is strict and code-path-driven; no real-device biometric/accessibility instrumentation (TalkBack/VoiceOver, dynamic font scale, low-vision contrast probes) was executed in this pass.

## Exit criteria for re-test
1. Fix CRITICAL-01 and all HIGH findings.
2. Re-run UX regression specifically on:
   - recommendation start flow
   - workout edit save navigation
   - plan form validation feedback
3. Re-issue release candidate and repeat strict UX audit.
