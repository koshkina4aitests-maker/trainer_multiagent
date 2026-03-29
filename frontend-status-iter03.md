# Frontend status — iter-03

## Scope delivered
- Active workout screen now shows planned targets per exercise:
  - `target_sets`, `target_reps`, optional `target_weight`
  - visual progress `completed_sets / target_sets`
- Post-workout summary includes post-session feeling capture (`fatigue`, `soreness`, `quality`).
- Plan details supports edit/delete actions:
  - rename workout
  - add/remove exercise
  - move planned date
  - delete planned workout
- Add-workout flow now supports selecting exercises from library with fallback "Create new".
- Rest timer UI added after set logging with default 90s and profile-based override.
- Profile page now shows/edit body metrics and goals:
  - height, weight, goal, health limitations
- Progress page has new "Wellbeing" tab with trend lines:
  - readiness fatigue/sleep
  - post-workout feeling trend

## Readiness
- `ready_for_pipeline=ok`
- blockers: none
- handoff: DevOps
