# UX Tester Report — iter-04

## Source
- Input from previous final regression backlog: `ux-final-iter03.md`
- Analyst perspective: `Fitness app user feedback`

## Scope for this iteration
1. Novice support when planned workout targets are repeatedly missed.
2. Sleep-vs-performance weekly trend annotation in progress analytics.

## Findings and user statements
1. **Missed-target context is still raw**  
   Users can see misses, but novices need immediate, non-judgmental guidance ("reduce weight", "extend rest", "switch variation").
2. **Trend graph is informative but not explanatory**  
   Users see sleep and performance values but need a concise weekly annotation ("this week better sleep correlated with improved completion").

## Priority
- High (P2): contextual novice coach hints after repeated misses.
- Medium (P1): weekly sleep-performance annotation.

## UX recommendations
- Add compact coach-hint cards after N consecutive missed targets (default N=2), with one primary suggestion.
- Add weekly annotation text over trend chart with confidence level (`low|medium|high`) to avoid overclaiming causality.

## Output artifact
- `ux-report-iter04.md`
