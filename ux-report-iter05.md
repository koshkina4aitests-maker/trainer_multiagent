# UX Requirements Intake — iter-05

## Source
- Direct stakeholder request (chat), iteration start `iter-05`.

## Requested changes

### 1) Profile
1. Remove default hardcoded user name "Алексей Смирнов".
2. Use name from Google account if available, otherwise keep empty.
3. Add preferred training style selection:
   - `split`
   - `fullbody`

### 2) Recommendations
1. Ask user which style to use for recommendation:
   - `fullbody`
   - `split upper`
   - `split lower`
2. Show recommended workout with explicit training payload:
   - exercise list
   - sets
   - reps
   - weight
3. Add action to copy recommended workout into Plan.

### 3) Plan
1. Exercise input must support dropdown suggestions and smart search.
2. Add structured fields per exercise row:
   - sets
   - reps
   - weight
   - RIR
3. Allow editing of recommended workout after it is copied to plan.

## Priority
- All requested items are `must` for this iteration scope.

## Expected UX outcome
- Reduced profile confusion (no fake default name).
- Recommendation flow becomes actionable and immediately plannable.
- Planning flow becomes structured and editable for real strength-training usage.
