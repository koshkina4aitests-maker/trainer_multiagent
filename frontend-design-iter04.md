# frontend-design-iter04.md

## Дизайнер -> Фронтендер (iter-04)

### Цель
Улучшить интерпретируемость тренировки для новичков и улучшить читаемость weekly correlation в Progress.

### UX-спеки
1. **Coach hints при missed planned targets**
   - На Active Workout и Post-workout Summary отображать компактный hint-chip, если пользователь 2+ раза подряд не достиг планового объема.
   - Варианты текста:
     - "Снизьте вес на 5–10% и удерживайте технику."
     - "Увеличьте отдых до 120 сек между подходами."
   - Hints dismissible, но доступны повторно через иконку "i".

2. **Weekly sleep-vs-performance annotation**
   - На Progress/Wellbeing overlay line chart:
     - sleep quality trend;
     - performance trend (volume/completion proxy).
   - Добавить аннотацию недели:
     - "На этой неделе: сон +12%, результат +8%".
   - При отсутствии данных: empty-state с подсказкой "Добавляйте оценку сна после тренировки".

### Инварианты
- Hint не перекрывает основные CTA.
- Аннотация размещается выше графика и не ломает responsive layout.
- Цветовые контрасты соответствуют WCAG AA.
