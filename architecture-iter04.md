# Fitness app architecture — Iteration 04

## Input artifacts
- UX source: `ux-report-iter04.md`
- Requirements: `requirements-iter04.md`

## Architectural deltas vs iter-03
1. **Missed-target coach hints**
   - Introduce a lightweight coaching-hint rule when user repeatedly misses planned set targets.
   - Trigger condition: missed target threshold in recent window (e.g., >= 2 misses for same exercise in last 3 sessions).
   - Output: compact hint object to Active Workout and Summary surfaces.

2. **Weekly sleep-vs-performance annotation**
   - Add aggregation endpoint for weekly correlation summary between sleep quality and performance trend.
   - Keep aggregation asynchronous-friendly for future scaling.

## API contract additions
- `GET /api/v1/workouts/coach-hints?user_id={id}&session_id={id}`
  - response:
    - `hints: [{ id, kind, short_text, related_exercise_id? }]`

- `GET /api/v1/progress/weekly-correlation?user_id={id}`
  - response:
    - `week_start`
    - `sleep_quality_avg`
    - `performance_delta`
    - `annotation_text`

## Domain/data notes
- Add `missed_target_event` capture at set-validation layer.
- Correlation annotations can be computed from existing readiness + session history; no mandatory schema migration.

## NFR impact
- Coach-hints endpoint p95 <= 250ms for current session context.
- Weekly-correlation endpoint p95 <= 700ms (cached aggregate allowed).

## Handoff
- Backend:
  - implement hint trigger rules and correlation endpoint.
  - ensure deterministic threshold config per user-level defaults.
- Frontend:
  - render compact hints without blocking logging flow.
  - render weekly annotation in Progress with concise non-medical wording.
- Designer:
  - provide compact hint component variants and annotation style tokens.
