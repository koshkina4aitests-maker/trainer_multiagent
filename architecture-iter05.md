# Fitness app architecture — Iteration 05

## Input artifacts
- UX source: `ux-report-iter05.md`
- Requirements: `requirements-iter05.md`

## Architectural deltas vs iter-04

### 1) Profile model extension
- Extend user profile payload with:
  - `display_name` (nullable, default `null`)
  - `training_style` (`split|fullbody|unset`)
- Name resolution rule:
  - use Google account display name when present;
  - otherwise keep empty value (no hardcoded fallback names).

### 2) Recommendation input + output enrichment
- Add recommendation input selector:
  - `recommendation_style`: `fullbody|split_upper|split_lower`
- Extend recommendation response:
  - `style_applied`
  - `exercises[]` with structured prescription fields:
    - `exercise_id`
    - `exercise_name`
    - `sets`
    - `reps`
    - `weight_kg` (nullable)
    - `rir` (nullable)
  - `copy_to_plan_supported: true`

### 3) Plan model normalization
- Replace text-only exercise rows with structured rows:
  - `exercise_id` (required)
  - `exercise_name` (display cache)
  - `sets`, `reps`, `weight_kg`, `rir`
- Preserve compatibility adapter for old plans that have only `exerciseNames`.

### 4) Plan editor search strategy
- Exercise picker contract:
  - dropdown list of recent and suggested items;
  - smart search (prefix + contains + translit-safe normalization if available);
  - fallback state when no matches with CTA "Create new exercise".

### 5) Recommendation-to-plan flow
- Add command/event:
  - `PlanCreateFromRecommendation(recommendation_id, editable=true)`
- Result:
  - created draft plan prefilled with prescription fields;
  - user can edit before save.

## API/contract updates

### Profile
- `PATCH /api/v1/profile/{user_id}`
  - accepts `display_name`, `training_style`
- `GET /api/v1/profile/{user_id}`
  - returns `display_name`, `training_style`

### Recommendation
- `POST /api/v1/recommendations/generate`
  - input adds `recommendation_style`
  - output includes structured `exercises[]` with sets/reps/weight/rir

### Plan
- `POST /api/v1/plans`
  - accepts structured exercise rows
- `PATCH /api/v1/plans/{id}`
  - supports edit for recommendation-derived plans

## Validation rules
- `training_style` must be one of `split|fullbody|unset`.
- Recommendation style must be one of `fullbody|split_upper|split_lower`.
- Exercise rows:
  - `sets >= 1`
  - `reps >= 1`
  - `weight_kg >= 0` when provided
  - `rir` in `[0..5]` when provided

## NFR impact
- Search response target: < 150ms p95 for local index.
- No regression on recommendation card render latency > +100ms.
- Backward compatibility for legacy plan records preserved.
- Web parity requirement: feature behavior and business rules must be consistent between mobile and web surfaces for Profile / Recommendations / Plan flows.

## Handoff
- Backend:
  - implement profile/training_style fields and recommendation structured payload.
  - add recommendation-to-plan creation endpoint path or command handler.
- Frontend:
  - remove hardcoded name fallback.
  - add profile style selector.
  - add recommendation style selector and structured recommendation UI.
  - implement copy-to-plan and editable plan form with smart exercise picker.
- Designer:
  - define compact UI patterns for prescription table rows and smart search dropdown states.

## Additional requirement — Web frontend parity
- Add frontend web implementation with functional parity to mobile release scope:
  1. Profile:
     - empty/default name behavior aligned with mobile,
     - training style selector (`fullbody`, `split`) with persistence.
  2. Recommendations:
     - style selector (`fullbody`, `split_upper`, `split_lower`),
     - detailed prescription preview (sets/reps/weight/RIR),
     - copy-to-plan CTA with editable result.
  3. Plan:
     - smart searchable exercise picker,
     - structured exercise fields (sets/reps/weight/RIR),
     - recommendation-derived workout editing.
- Contract rule:
  - one source of truth for validation and domain constraints across mobile/web.
- UX rule:
  - web layouts can differ visually, but user intent, outcomes, and data semantics must match mobile behavior.
