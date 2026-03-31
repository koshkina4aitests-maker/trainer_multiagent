# UX Retest Report — iter-07 (plan workout edit labels)

## Requirement
- fix design in planned workout edit screen so field labels are fully visible.

## Scope
- file: `flutter_app/lib/features/plan/presentation/pages/workout_details_page.dart`
- screen: bottom sheet "Редактировать тренировку"

## Implemented changes
1. Field labels changed from short abbreviations to full names:
   - `Подх` -> `Подходы`
   - `Повт` -> `Повторы`
   - `Вес` -> `Вес (кг)`
2. Numeric input block made adaptive:
   - narrow width (`< 560`): rendered as 2x2 grid rows
   - wider width: rendered as single row of 4 fields
3. Labels forced to stay visible:
   - `floatingLabelBehavior: FloatingLabelBehavior.always`

## Verification
- `flutter analyze`: passed
- `flutter test`: passed

## UX verdict
- status: `passed`
- blockers: none
- note: labels are readable without clipping on compact and wide layouts.
