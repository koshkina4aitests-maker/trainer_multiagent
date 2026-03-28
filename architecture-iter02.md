# Fitness app architecture — Iteration 02

## Input artifacts
- UX source: `ux-report-iter02.md`
- Requirements: `requirements-iter02.md`

## Architectural deltas vs iter-01
1. **Recommendation explanation support**
   - Extend recommendation payload with concise explanation fields:
     - `intensity_label` (`easy|moderate|hard`)
     - `intensity_reason_short` (string, max 120 chars)
   - Rationale: allows novice-friendly one-line explanation in UI without extra API calls.

2. **Dashboard action target constraints**
   - Add UI contract constraint for secondary quick actions:
     - `min_touch_target_px`: `44`
   - Include design token mapping for hit areas in frontend component library.

## API contract additions
- `GET /api/v1/workouts/recommendation?user_id={id}`
  - response additions:
    - `intensity_label: string`
    - `intensity_reason_short: string`

## Data and validation notes
- No schema migration required for `intensity_reason_short` if computed on service side.
- If persisted for analytics, store nullable text in recommendation snapshot table.

## NFR impact
- Response size increase expected < 5%.
- No change to p95 latency budget target.

## Handoff
- Backend: implement response extension + validation length cap.
- Frontend: render one-line explanation and enforce 44px quick-action tap target.
- Designer: provide tokenized spacing/hitbox guidance for cards.
