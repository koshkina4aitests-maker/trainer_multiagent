# Backend status — iter-05

## Scope delivered
1. **Profile model**
   - Added `display_name` policy:
     - populate from Google profile when available;
     - keep empty when Google name is unavailable;
     - removed any hardcoded default user full name.
   - Added `training_style_preference` enum:
     - `fullbody`
     - `split_upper`
     - `split_lower`
     - `split_generic`

2. **Recommendation API**
   - Extended recommendation request with `preferred_style`.
   - Recommendation response includes structured exercise prescriptions:
     - `sets`
     - `reps`
     - `target_weight`
     - `rir`
   - Added style-aware recommendation branch selection for fullbody/split.

3. **Plan data model**
   - Added normalized plan item fields:
     - `exercise_id`
     - `exercise_name`
     - `sets`
     - `reps`
     - `target_weight`
     - `rir`
   - Added endpoints/use-cases for:
     - copying recommendation into plan draft;
     - editing copied recommendation before save.

## Technical notes
- Backward compatibility maintained for legacy plain-text plan entries during migration window.
- Validation added for non-negative weight, sets/reps lower bounds, and RIR range.
- Search endpoint supports prefix + fuzzy matching for exercise suggestions.

## Readiness
- `ready_for_pipeline=ok`
- blockers: none
- handoff: DevOps
