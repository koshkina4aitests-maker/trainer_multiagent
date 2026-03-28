# Fitness app requirements — iter-02

## Source
- Input UX report: `ux-report-iter02.md`
- Analyst: Бизнес-аналитик «Fitness app requirements»
- Iteration: `iter-02`

## Prioritized requirements

### MUST
1. **Recommended intensity explanation for novice users**
   - On workout recommendation cards, show one-line contextual explanation under intensity label.
   - The explanation must clarify why this intensity is selected for beginners.
   - **AC:** for novice level users, intensity explanation is visible in recommendation area on Dashboard and Workout Detail.

2. **Secondary quick-action tap targets**
   - Secondary quick actions in Dashboard cards must have larger interactive area.
   - Minimum touch target for mobile: 44x44 CSS px.
   - **AC:** quick actions are operable with one-tap usage on mobile in usability validation.

### SHOULD
1. **Consistent helper copy style**
   - Explanation line uses shared microcopy style tokens (size, color, spacing) for readability.
   - **AC:** helper copy does not break card layout at common mobile widths.

2. **Interaction analytics for quick actions**
   - Emit analytics event for secondary action taps to validate discoverability improvements.
   - **AC:** events are produced with card/action metadata and can be queried by day.

### COULD
1. **Progressive disclosure**
   - Optional “Why this intensity?” inline expander for additional context.

## Non-functional requirements
- No regression in Dashboard first contentful render beyond +100ms vs `iter-01`.
- Maintain WCAG AA contrast for helper text.
- Keep event payload backward compatible with existing analytics processing.

## Dependencies and risks
- Requires frontend token alignment for helper copy style.
- Requires backend/analytics endpoint contract for new quick-action events.
