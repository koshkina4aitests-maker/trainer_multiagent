# Frontend status — iter-05

## Scope delivered
1. **Profile**
   - Removed hardcoded default name ("Алексей Смирнов").
   - Name now sourced from Google account when available; otherwise empty placeholder shown.
   - Added profile preference: training style (`split`, `fullbody`).

2. **Recommendations**
   - Added pre-recommendation selector:
     - `fullbody`
     - `split upper`
     - `split lower`
   - Recommendation card now includes exercise rows with planned:
     - sets
     - reps
     - target weight
     - RIR
   - Added CTA: **"Копировать в план"** (creates editable plan draft from recommendation).

3. **Plan**
   - Replaced plain exercise text input with searchable dropdown + smart search suggestions.
   - Added structured fields per exercise row:
     - sets
     - reps
     - weight
     - RIR
   - Added edit mode for copied recommended workout.

## Readiness
- `ready_for_pipeline=ok`
- blockers: none
- handoff: DevOps
