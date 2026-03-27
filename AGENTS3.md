# AGENTS3: Интерактивные прототипы Fitness App через Figma API

## 1) Цель

На основании артефактов, подготовленных агентами:

- `Fitness app requirements`
- `Fitness app architecture`

сгенерировать интерактивные прототипы интерфейса Fitness App в Figma, включая:

1. ключевые экраны;
2. пользовательские сценарии (end-to-end flows);
3. основные элементы навигации;
4. переиспользуемые UI-шаблоны (компоненты, стили, токены).

---

## 2) Входные данные (Source of Truth)

Перед генерацией прототипа обязательно извлечь из требований и архитектуры:

- роли пользователей (например: new user, active user, coach/admin);
- основные use-cases и user stories;
- функциональные модули (тренировки, план, прогресс, профиль, подписка и т.д.);
- ограничения архитектуры (API, состояния offline/online, ошибки, авторизация);
- нефункциональные ожидания (доступность, локализация, responsive поведение).

Если в `requirements`/`architecture` названия модулей отличаются от перечисленных ниже, использовать **названия из исходных документов**.

---

## 3) Структура Figma-файла (шаблон)

Создать один Figma-файл: `Fitness App - Interactive Prototype`.

Страницы:

1. `00_Cover & Notes`
2. `01_Information Architecture`
3. `02_Design Tokens`
4. `03_Components Library`
5. `04_Wireframes`
6. `05_High-Fidelity Screens`
7. `06_Interactive Flows`
8. `07_Edge Cases & Errors`

---

## 4) Основные элементы навигации

### 4.1 Глобальная структура

- Auth stack:
  - Welcome
  - Sign in / Sign up
  - Forgot password
- Main app (Bottom Tab Bar):
  - Home
  - Plan
  - Workouts
  - Progress
  - Profile
- Modal/Overlay:
  - Quick start workout
  - Filters / Selectors
  - Confirmation dialogs

### 4.2 Правила прототипирования навигации

- Каждый primary CTA должен иметь интеракцию (`On click -> Navigate`).
- Back navigation должна работать на всех вложенных экранах.
- Для bottom tabs: постоянный active state + переходы между вкладками.
- Для deep links: как минимум 2 сценария (например, открытие конкретной тренировки, открытие экрана прогресса).

---

## 5) Ключевые экраны (минимальный набор)

### Onboarding/Auth

1. Welcome / Value proposition
2. Goal selection
3. Personal metrics input
4. Sign in
5. Sign up
6. Password recovery

### Core Experience

7. Home dashboard
8. Workout plan (week view)
9. Workout details
10. Exercise player / active workout
11. Post-workout summary
12. Progress dashboard
13. History / logs
14. Profile & settings
15. Notifications center

### Edge/Error States

16. Empty state (no workouts)
17. Offline state
18. API error / retry
19. Permission denied (notifications/health data)

---

## 6) Пользовательские сценарии (интерактивные потоки)

Собрать минимум 6 end-to-end flow:

1. **Первый запуск**: Welcome -> Goal setup -> Registration -> Home.
2. **Быстрый старт тренировки**: Home -> Quick Start -> Active Workout -> Summary.
3. **Плановая тренировка**: Plan -> Workout details -> Start -> Complete -> Progress update.
4. **Отслеживание прогресса**: Home -> Progress -> Filter period -> Drill-down metric.
5. **Редактирование профиля**: Profile -> Edit data -> Save -> Success feedback.
6. **Негативный сценарий**: Action -> API error -> Retry -> Success/Failure.

Для каждого сценария добавить:

- стартовый экран;
- триггер действия;
- ожидаемый результат;
- альтернативные ветки (error/cancel/back).

---

## 7) Design tokens и библиотека компонентов

### 7.1 Tokens

Минимально задать:

- Color primitives + semantic colors (bg, text, success, warning, error);
- Typography scale (H1..H6, body, caption);
- Spacing scale (4/8/12/16/24/32);
- Radius/elevation;
- Motion durations (fast/normal/slow).

### 7.2 Components

Создать минимум:

- Buttons (primary/secondary/ghost, default/disabled/loading);
- Inputs (text, numeric, search, validation states);
- Cards (workout card, progress card);
- Tab bar + tab item;
- Navigation bar;
- Chips/filters;
- Modal/dialog;
- Toast/snackbar;
- Progress indicators.

Все компоненты должны иметь варианты (`variant properties`) и быть связаны с токенами.

---

## 8) Использование Figma API для генерации шаблонов

> Важно: для **создания и изменения узлов** использовать Figma **Plugin API** (внутри файла Figma).  
> Figma REST API использовать для чтения структуры, проверки, экспорта и комментариев.

### 8.1 Шаблон входной спецификации (`prototype-spec.json`)

```json
{
  "fileName": "Fitness App - Interactive Prototype",
  "pages": [
    "00_Cover & Notes",
    "01_Information Architecture",
    "02_Design Tokens",
    "03_Components Library",
    "04_Wireframes",
    "05_High-Fidelity Screens",
    "06_Interactive Flows",
    "07_Edge Cases & Errors"
  ],
  "screens": [
    { "id": "welcome", "name": "Welcome", "page": "05_High-Fidelity Screens" },
    { "id": "signin", "name": "Sign In", "page": "05_High-Fidelity Screens" },
    { "id": "home", "name": "Home Dashboard", "page": "05_High-Fidelity Screens" },
    { "id": "workout_details", "name": "Workout Details", "page": "05_High-Fidelity Screens" },
    { "id": "active_workout", "name": "Active Workout", "page": "05_High-Fidelity Screens" },
    { "id": "summary", "name": "Post-workout Summary", "page": "05_High-Fidelity Screens" },
    { "id": "progress", "name": "Progress Dashboard", "page": "05_High-Fidelity Screens" },
    { "id": "profile", "name": "Profile", "page": "05_High-Fidelity Screens" }
  ],
  "flows": [
    {
      "name": "First Launch",
      "steps": ["welcome", "signin", "home"]
    },
    {
      "name": "Quick Workout",
      "steps": ["home", "workout_details", "active_workout", "summary", "progress"]
    }
  ]
}
```

### 8.2 Каркас Plugin API (TypeScript, псевдокод)

```ts
// 1) Прочитать prototype-spec.json
// 2) Создать страницы
// 3) Для каждого экрана создать Frame (390x844), базовый layout, nav shell
// 4) Создать компоненты и варианты в Components Library
// 5) Проставить прототипные связи между фреймами согласно flows

const SCREEN_W = 390;
const SCREEN_H = 844;

function createScreenFrame(name: string): FrameNode {
  const frame = figma.createFrame();
  frame.name = name;
  frame.resize(SCREEN_W, SCREEN_H);
  frame.layoutMode = "VERTICAL";
  frame.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  return frame;
}

// Пример: назначение стартовой точки прототипа
// flowStartNode.setRelaunchData({ openPrototype: "true" });

// Пример: псевдоназначение связи
// ctaButton.reactions = [{ trigger: { type: "ON_CLICK" }, action: { type: "NODE", destinationId: target.id } }];
```

### 8.3 REST API (проверка и экспорт)

Переменные окружения:

- `FIGMA_TOKEN`
- `FIGMA_FILE_KEY`

Примеры запросов:

```bash
# Получить структуру файла
curl -sS -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/$FIGMA_FILE_KEY"

# Получить конкретные ноды
curl -sS -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/$FIGMA_FILE_KEY/nodes?ids=1:2,1:3"

# Экспортировать экраны в PNG
curl -sS -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/$FIGMA_FILE_KEY?ids=1:2,1:3&format=png&scale=2"
```

---

## 9) Критерии готовности (Definition of Done)

Считать задачу выполненной, если:

1. В Figma создана структура страниц по шаблону.
2. Есть минимум 15 ключевых экранов + edge/error states.
3. Настроены минимум 6 пользовательских интерактивных сценариев.
4. Bottom tab и back navigation работают в прототипе.
5. Есть библиотека компонентов и токенов, используемая экранами.
6. Экспорт ключевых экранов через REST API проходит без ошибок.
7. Прототип соответствует требованиям и архитектурным ограничениям из исходных документов.

---

## 10) Артефакты, которые нужно вернуть

1. Ссылка на Figma-файл.
2. Ссылка на страницу `06_Interactive Flows`.
3. Таблица соответствия:
   - requirement -> screen(s) -> flow(s).
4. Список нерешённых вопросов/допущений.
5. Набор экспортов экранов (PNG) для ревью.
