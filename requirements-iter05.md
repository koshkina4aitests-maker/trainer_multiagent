# Fitness app requirements — iter-05

## Source
- Input: direct stakeholder requirements (2026-03-29)
- Analyst: Бизнес-аналитик «Fitness app requirements»
- Iteration: `iter-05`

## Scope summary
Focus areas:
1. Profile improvements (name handling + training style)
2. Recommendation flow enhancements (style selector + detailed prescription + copy-to-plan)
3. Plan authoring/editing enhancements (exercise picker + set-level fields + editable recommendation)
4. Web frontend parity with mobile functionality

## Prioritized requirements

### MUST
1. **Profile name source correction**
   - Remove hardcoded default name "Алексей Смирнов".
   - Use Google account display name when available.
   - If Google name is unavailable, keep profile name empty (no fake default).
   - **AC:** new and existing users no longer see hardcoded default name.

2. **Training style in profile**
   - Add user preference field: `training_style` with options:
     - `fullbody`
     - `split`
   - Persist profile preference and expose in profile UI and recommendation context.
   - **AC:** user can view/edit saved training style in Profile.

3. **Recommendation style selector**
   - Before generating recommendation, ask user preferred recommendation style:
     - `fullbody`
     - `split_upper`
     - `split_lower`
   - Recommendation engine must consume this selector.
   - **AC:** recommendation request payload includes selected style.

4. **Detailed recommended workout prescription**
   - Recommendation output must include exercise-level prescription:
     - sets
     - reps
     - weight
     - RIR
   - **AC:** recommendation card/details show these fields clearly.

5. **Copy recommendation to plan**
   - Add action to copy recommended workout into plan.
   - Copied plan item must include prescribed fields (sets/reps/weight/RIR).
   - **AC:** user can copy in one action and find workout in plan for selected date.

6. **Plan exercise picker with smart search**
   - In plan editor, replace plain text exercise input with:
     - dropdown suggestions
     - smart search over exercise library
   - **AC:** user can quickly find/select exercise and avoid free-text mismatch.

7. **Plan set-level fields**
   - For each exercise in plan, support fields:
     - sets
     - reps
     - weight
     - RIR
   - **AC:** values can be entered, edited, and persisted.

8. **Edit recommended workout**
   - After copying recommendation to plan, user can edit workout content:
     - exercises list
     - sets/reps/weight/RIR
   - **AC:** recommendation-derived plan item is fully editable.

9. **Web frontend functional parity**
   - Deliver web frontend behaviorally equivalent to mobile app for core flows:
     - Profile (name logic + training style)
     - Recommendations (style selector + detailed prescription + copy-to-plan)
     - Plan (smart exercise picker + sets/reps/weight/RIR + edit recommendation-derived workout)
     - Workout run flow (start, logging sets, completion summary)
   - **AC:** all listed flows are available on web with same business rules, validations, and data persistence semantics.

### SHOULD
1. **Profile defaults interplay**
   - If profile has `training_style`, preselect this value in recommendation style selector.
2. **Validation and UX guardrails**
   - Enforce numeric validation ranges for sets/reps/weight/RIR.
3. **Consistency in all plan entry points**
   - Same exercise picker and set-level editor in add, edit, and recommendation-derived flows.
4. **Cross-platform consistency**
   - UI copy and state transitions remain consistent between mobile and web to avoid behavior divergence.

### COULD
1. **Quick templates for style**
   - Offer prefilled templates for fullbody / split upper / split lower.
2. **Recent exercise boosting in search ranking**
   - Prioritize recently used exercises in smart search results.

## Non-functional requirements
- No regression in existing recommendation and plan load flows.
- Form interactions should remain mobile-friendly (tap targets >= 44 px).
- Persisted data remains backward-compatible with existing local storage payloads.

## Dependencies and risks
- Requires plan domain model extension for set-level prescription data.
- Requires migration logic for old plan records without new fields.
- Smart search quality depends on exercise library normalization.
- Web parity requires responsive layout adaptations and additional QA matrix (desktop + tablet breakpoints).
