# Fitness app requirements — iter-01

## Source
- Input UX report: `ux-report-iter01.md`
- Analyst: Бизнес-аналитик «Fitness app requirements»
- Iteration: `iter-01`

## Prioritized requirements

### MUST
1. **Onboarding with clear goal selection**
   - User must choose one primary goal (weight loss, muscle gain, endurance, habit).
   - Progress bar and short explanation must be present on each onboarding step.
   - **AC:** completion rate of onboarding is measurable and step drop-off is logged.

2. **Session state persistence**
   - Active workout session state must survive app background/foreground transitions.
   - **AC:** app resumes the same timer and exercise index after reopen.

3. **Plan card readability**
   - Plan cards must use high-contrast text and explicit CTA labels.
   - **AC:** contrast ratio meets WCAG AA for primary text.

4. **Network error handling with retry**
   - Any loading error on plans/dashboard must show recoverable error state with Retry.
   - **AC:** user can retry without relaunching app.

### SHOULD
1. **Weekly schedule preview**
   - Show a compact 7-day preview in dashboard.
   - **AC:** each day indicates workout/rest status.

2. **Warm-up recommendations**
   - Add quick warm-up suggestions before first set.
   - **AC:** visible before workout start and dismissible.

### COULD
1. **Personalized motivational copy**
   - Contextual microcopy based on selected onboarding goal.
2. **Animated transitions between workout steps**
   - Keep subtle animations without performance regression.

## Non-functional requirements
- App startup (warm) < 2.5s on reference device.
- Retry action response under normal network < 1s until request dispatch.
- Crash-free session target: >= 99.5%.
- Accessibility: keyboard/screen-reader labels on major CTAs.

## Dependencies and risks
- Requires API support for weekly schedule endpoint.
- Need alignment on analytics events naming for onboarding drop-off.
