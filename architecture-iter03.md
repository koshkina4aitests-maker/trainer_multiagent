# Fitness app architecture — Iteration 03

## Input artifacts
- UX source: `ux-report-iter03.md`
- Requirements: `requirements-iter03.md`

## Architectural deltas vs iter-02
1. **Planned vs completed visibility in active workout**
   - Extend active workout payload with `planned_sets`, `planned_reps`, optional `planned_weight`.
   - Add derived progress counters per exercise (`completed_sets`, `remaining_sets`).
   - Enable stable UI contract for line: `Цель: X подходов × Y повт`.

2. **Post-workout feeling capture**
   - Add `post_workout_feeling` object to workout session close flow:
     - `fatigue`, `muscle_soreness`, `session_quality` (1..10)
   - Store together with session summary for recommendation feedback loop.

3. **Plan CRUD support**
   - Expand planning API/contracts with update/delete:
     - `PATCH /api/v1/plan/workouts/{id}`
     - `DELETE /api/v1/plan/workouts/{id}`
   - Add domain events matching agent remark: `PlanWorkoutUpdated`, `PlanWorkoutDeleted`.

4. **Exercise catalog binding in plan creation**
   - Replace text-only exercise input with catalog reference:
     - `planned_workout_exercise.exercise_id` (required)
   - Keep optional free-text note as fallback only.

5. **Rest timer and profile data management**
   - Add profile preference `default_rest_timer_sec` (default 90).
   - Expose profile fields for edit/read:
     - `height_cm`, `weight_kg`, `goal`, `health_constraints`.

6. **Wellbeing analytics in progress**
   - Extend progress aggregation with readiness and post-workout feeling series.
   - New dataset for trend charts in `ProgressPage/Самочувствие`.

## API additions/changes
- `GET /api/v1/active-workout/{session_id}` -> includes planned targets and completion progress.
- `POST /api/v1/sessions/{id}/feeling` -> stores post-workout feeling.
- `PATCH /api/v1/plan/workouts/{id}`
- `DELETE /api/v1/plan/workouts/{id}`
- `GET /api/v1/exercises` for searchable picker in plan creation.
- `PATCH /api/v1/profile/{user_id}` supports body metrics + goal + constraints + rest timer.
- `GET /api/v1/progress/wellbeing?range={7d|30d|90d}`

## Data model updates
- `session_exercise_targets` (session_id, exercise_id, planned_sets, planned_reps, planned_weight)
- `session_feeling` (session_id, fatigue, muscle_soreness, session_quality, created_at)
- `planned_workout_exercises` now references `exercise_id` FK.
- `user_profile` adds editable body/goal/constraint fields + `default_rest_timer_sec`.

## NFR / constraints
- No regression in session logging latency > +100ms p95.
- Profile update and plan edit/delete must be idempotent and auditable.
- Migration required for plan exercise references and profile attributes.

## Handoff
- Backend: implement API/data model changes and migration scripts.
- Frontend: add UI for targets visibility, post-workout feeling, plan edit/delete, catalog picker, rest timer, profile data form, wellbeing charts.
- Designer: refine interaction patterns for plan editor and wellbeing visualization.
