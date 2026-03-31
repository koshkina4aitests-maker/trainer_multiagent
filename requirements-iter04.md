# Fitness app requirements — iter-04

## Source
- Input UX report: `ux-report-iter04.md`
- Analyst: Бизнес-аналитик «Fitness app requirements»
- Iteration: `iter-04`

## Prioritized requirements

### MUST
1. **Novice miss-pattern coach hints**
   - When a novice user repeatedly misses planned set targets, show compact contextual coaching hint in active workout.
   - Trigger condition: at least 2 missed planned targets within a single session, or 3 within rolling 7 days.
   - **AC:** hint appears only when trigger condition is met; hint includes one recommended corrective action.

2. **Hint explainability and dismissal**
   - Each coach hint must include concise "why this appears" explanation and quick dismiss action.
   - **AC:** dismissed hint is not re-shown for the same exercise within current session.

### SHOULD
1. **Sleep vs performance weekly annotation**
   - In progress area, add weekly annotation that explains trend relation between sleep quality and performance score.
   - **AC:** annotation displays "positive", "neutral", or "negative" trend label with confidence note.

2. **Backlog-safe telemetry**
   - Emit analytics event for hint trigger and hint action (`shown`, `dismissed`, `accepted`).
   - **AC:** event schema remains backward compatible with existing analytics ingestion.

### COULD
1. **User preference toggle for hints**
   - Add profile-level toggle to reduce coaching hint frequency.

## Non-functional requirements
- No visible regression in active workout interaction latency (>100ms vs iter-03 baseline).
- Trend annotation computation must complete within existing progress summary SLA budget.
- Accessibility: hint component must be screen-reader friendly and keyboard-focusable on web.

## Dependencies and risks
- Requires trend aggregation from readiness + session outcome metrics.
- False-positive hint risk for users intentionally doing deload/light days.
- Needs copy alignment with UX tone guidelines for novice users.
