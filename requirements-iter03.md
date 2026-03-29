# Fitness app requirements — iter-03

## Source
- Input UX report: `ux-report-iter03.md`
- Analyst: Бизнес-аналитик «Fitness app requirements»
- Iteration: `iter-03`

## Prioritized requirements

### MUST (priority 3)
1. **Planned parameters in active workout**
   - While running a workout, user must see planned sets/reps/weight target for each exercise.
   - Progress indicator must show planned vs completed sets.
   - **AC:** in `ActiveWorkoutPage`, each exercise displays "Цель: X подходов × Y повт. × Z кг (если задано)" and completed sets counter.

2. **Post-workout feeling capture**
   - After workout completion, app must capture post-workout feeling (fatigue/soreness/training quality).
   - Persist as `postWorkoutFeeling` in workout session history.
   - **AC:** `PostWorkoutSummaryPage` includes mandatory feedback step before final save.

3. **Plan workout editing/deletion**
   - User must be able to edit, reschedule, and delete planned workouts.
   - **AC:** `WorkoutDetailsPage` provides Edit/Delete actions; `PlanBloc` supports update/delete events.

### SHOULD (priority 2)
4. **Exercise selection from library in plan flow**
   - `_AddWorkoutSheet` must select exercises from exercise library instead of free text.
   - Store `exerciseId` in planned workout entries.
   - **AC:** exercise picker supports search + quick create.

5. **Rest timer between sets**
   - After set logging, rest timer should start automatically with configurable default.
   - **AC:** visible countdown with completion notification/vibration hook.

6. **Editable body metrics and goals in profile**
   - Profile must display and allow editing of height/weight/goal/health restrictions.
   - **AC:** Profile contains "Мои данные" with edit flow and persisted updates.

### COULD (priority 1)
7. **Well-being dynamics in progress analytics**
   - Progress screen should include well-being trends (fatigue/sleep/soreness) over time.
   - **AC:** "Самочувствие" tab renders at least two line charts based on readiness and post-workout data.

## Non-functional requirements
- No data-loss for logged sets/session feeling under app background/foreground transitions.
- New profile and planning mutations must be idempotent on retries.
- Analytics events for new UX interactions remain backward compatible.

## Dependencies and risks
- Requires extension of domain models (`PlannedWorkout`, `WorkoutSession`, profile payload).
- Requires coordination between Plan/Workout/Profile state managers.
- Requires migration path for legacy planned workouts stored as plain exercise text.
