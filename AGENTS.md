# AGENTS.md — Flutter Frontend Development Agent

## Роль

Ты **Senior Flutter Developer**.

Твоя задача — разработать полнофункциональный Flutter-фронтенд для фитнес-приложения на основе:

- требований из агента **Fitness app requirements** (`AGENTS1.md`);
- архитектуры из агента **Fitness app architecture** (`AGENTS2.md`);
- дизайна и прототипов из агента **Интерактивные прототипы фитнес-приложения** (`AGENTS3.md` + `artifacts/prototypes/`).

Ты пишешь production-ready Dart/Flutter код с корректной архитектурой, полным покрытием ключевых пользовательских сценариев, отзывчивым интерфейсом и надёжной интеграцией с backend API.

---

## Входные данные (Sources of Truth)

### Требования (из AGENTS1.md / Fitness app requirements)

**MVP в scope:**
- Google-аутентификация.
- Ручное создание и планирование тренировок.
- Хранение истории тренировок.
- Рекомендации тренировок на основе истории и анализа текущего состояния.
- Добавление упражнений в базу упражнений.

**Целевая аудитория:** обычные пользователи спортзалов (не профессиональные атлеты), 25–55 лет.

**Платформа MVP:** web-приложение с адаптивным responsive-layout. Код пиши на Flutter с поддержкой web. Мобильные платформы (iOS/Android) должны быть готовы к запуску без архитектурных изменений.

**Медицинские ограничения (MVP):** боль в спине, боль в суставах (включая колени), гипотиреоз.

**Безопасность:** риск-скрининг, предупреждения, экстренные инструкции.

**Логирование тренировки (минимум):** упражнение, количество подходов, повторы на подход, вес, RIR.

**Рекомендации:** гибридный подход (правила + AI), объяснение рекомендаций ("почему эта тренировка").

**Локаль:** Российская Федерация (русский язык основной, поддержка английского приветствуется).

**Аутентификация:** Google Sign-In.

---

### Архитектура backend (из AGENTS2.md / Fitness app architecture)

**Доменные контексты backend (bounded contexts):**

| № | Контекст | Ключевые сущности |
|---|----------|-------------------|
| 1 | Identity & Access | User, Token, Role |
| 2 | User Profile & Goals | Profile, HealthLimits, Goal |
| 3 | Training Program | Program, Exercise, Schedule |
| 4 | Workout Tracking | Session, Set, Rep, Weight, RIR, HeartRate |
| 5 | Nutrition | NutritionPlan, FoodLog |
| 6 | Progress & Insights | Metrics, Charts, Reports |
| 7 | Engagement | Streaks, Achievements, Reminders |
| 8 | Subscription & Billing | Plan, Subscription, BillingEvent |
| 9 | Content Management | Articles, Media |
| 10 | Analytics & Experimentation | Events, Funnels, A/B |

**API:**
- REST API `/v1/...`, версионированные DTO.
- OAuth2/OIDC, short-lived access token + refresh rotation.
- HTTPS everywhere.

**NFR:**
- P95 read latency ≤ 300 ms, write ≤ 500 ms.
- Graceful degradation при недоступности вторичных функций.

---

### Дизайн (из AGENTS3.md + artifacts/prototypes/)

**Цветовые токены:**

```dart
// Основные цвета (из generate_fitness_prototypes.py)
const Color kColorBg          = Color(0xFFF7F9FC);
const Color kColorCard         = Color(0xFFFFFFFF);
const Color kColorText         = Color(0xFF171F35);
const Color kColorMuted        = Color(0xFF747D96);
const Color kColorPrimary      = Color(0xFF4263EB);
const Color kColorPrimaryDark  = Color(0xFF2C4AC7);
const Color kColorSuccess      = Color(0xFF27AE60);
const Color kColorWarning      = Color(0xFFF2994A);
const Color kColorError        = Color(0xFFEB5757);
const Color kColorBorder       = Color(0xFFE1E7F0);
```

**Типографика:** шкала H1–H6, body, caption. Межсимвольное расстояние стандартное. Для русского языка — системные шрифты или Google Fonts (Roboto / Inter).

**Отступы:** шкала 4/8/12/16/24/32 dp.

**Радиус скруглений:** карточки — 16, кнопки — 14, chips/inputs — 12.

**Экраны прототипа (viewport 390×844, аналог iPhone 14):**

| # | Файл | Экран |
|---|------|-------|
| 01 | `01_welcome.png` | Welcome / Value proposition |
| 02 | `02_sign_in.png` | Sign In / Sign Up |
| 03 | `03_home.png` | Home Dashboard |
| 04 | `04_plan.png` | Workout Plan (week view) |
| 05 | `05_workout_details.png` | Workout Details |
| 06 | `06_active_workout.png` | Active Workout / Exercise Player |
| 07 | `07_post_workout_summary.png` | Post-Workout Summary |
| 08 | `08_progress.png` | Progress Dashboard |
| 09 | `09_profile.png` | Profile & Settings |
| 10 | `10_empty_state.png` | Empty State |
| 11 | `11_offline_state.png` | Offline State |
| 12 | `12_api_error.png` | API Error / Retry |

**Компонентная библиотека (минимум):**
- Buttons: primary / secondary / ghost; default / disabled / loading.
- Inputs: text, numeric, search; validation states.
- Cards: WorkoutCard, ProgressCard.
- BottomTabBar + TabItem (5 табов: Home, Plan, Workouts, Progress, Profile).
- AppBar / NavigationBar.
- Chips / Filters.
- Modal / Dialog.
- Toast / Snackbar.
- Progress indicators (linear, circular).

---

## Архитектура Flutter-приложения

### Технологический стек

| Слой | Библиотека / подход |
|------|---------------------|
| State management | `flutter_bloc` (BLoC/Cubit) |
| Navigation | `go_router` |
| DI / Service locator | `get_it` + `injectable` |
| Networking | `dio` + `retrofit` |
| Local storage | `flutter_secure_storage` (tokens), `hive` или `shared_preferences` (кэш) |
| Google Auth | `google_sign_in` |
| Serialization | `freezed` + `json_serializable` |
| Charts | `fl_chart` |
| Adaptive UI | `flutter_adaptive_scaffold` или ручной `LayoutBuilder` |
| Internationalization | `flutter_localizations` + `intl` |
| Testing | `flutter_test`, `mocktail`, `bloc_test` |

### Структура директорий

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp + GoRouter + DI init
│   ├── router/
│   │   └── app_router.dart         # Все маршруты
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_text_styles.dart
│       └── app_spacing.dart
├── core/
│   ├── di/
│   │   └── injection.dart          # get_it + injectable setup
│   ├── network/
│   │   ├── api_client.dart         # Dio + interceptors
│   │   ├── auth_interceptor.dart   # Token refresh
│   │   └── error_handler.dart
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   └── utils/
│       ├── validators.dart
│       └── date_utils.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── token_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       └── sign_out.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── welcome_page.dart
│   │           └── sign_in_page.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── goal_selection_page.dart
│   │           └── personal_metrics_page.dart
│   ├── home/
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart
│   ├── plan/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       └── pages/
│   │           ├── plan_page.dart
│   │           └── workout_details_page.dart
│   ├── workout/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       └── pages/
│   │           ├── active_workout_page.dart
│   │           └── post_workout_summary_page.dart
│   ├── progress/
│   │   └── presentation/
│   │       └── pages/
│   │           └── progress_page.dart
│   └── profile/
│       └── presentation/
│           └── pages/
│               └── profile_page.dart
└── shared/
    ├── widgets/
    │   ├── app_button.dart
    │   ├── app_card.dart
    │   ├── app_input.dart
    │   ├── app_bottom_nav.dart
    │   ├── app_snackbar.dart
    │   ├── app_dialog.dart
    │   ├── empty_state_widget.dart
    │   ├── error_state_widget.dart
    │   └── offline_banner.dart
    └── models/
        └── paginated_response.dart
```

### Принципы Clean Architecture

1. **Слои:** `data` -> `domain` -> `presentation`. Зависимости только внутрь.
2. **Domain** не зависит ни от Flutter, ни от сторонних библиотек.
3. **Use Cases** — один use case = одна публичная бизнес-операция.
4. **BLoC/Cubit** — только в `presentation`. Бизнес-логика в use cases.
5. **Repository pattern** — интерфейс в `domain`, реализация в `data`.

---

## Ключевые пользовательские сценарии

### Сценарий 1: Первый запуск (Onboarding)

```
Welcome -> Google Sign-In -> Goal Selection -> Personal Metrics -> Health Limits -> Home
```

**Экраны:** `welcome_page`, `sign_in_page`, `goal_selection_page`, `personal_metrics_page`.

**Шаги реализации:**
1. `WelcomePage`: value proposition, CTA "Начать" + "Войти". Соответствует `01_welcome.png`.
2. `SignInPage`: кнопка Google Sign-In, обработка ошибок. Соответствует `02_sign_in.png`.
3. `GoalSelectionPage`: чипы выбора цели (похудение / сила / выносливость / здоровье).
4. `PersonalMetricsPage`: форма (возраст, рост, вес, пол). Валидация полей.
5. `HealthLimitsPage`: чекбоксы медицинских ограничений (боль в спине, суставах, гипотиреоз) + предупреждение о том, что это не медицинский совет.
6. После onboarding — redirect на `HomePage`, onboarding-флаг сохраняется локально.

**BLoC:** `AuthBloc` (события: `GoogleSignInRequested`, `SignOutRequested`; состояния: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`).

**GoRouter:** route guard — если `AuthAuthenticated`, редирект с auth-стека на `/home`.

---

### Сценарий 2: Быстрый старт тренировки

```
Home -> Quick Start -> Active Workout -> Post-Workout Summary -> Progress update
```

**Экраны:** `home_page`, `active_workout_page`, `post_workout_summary_page`.

**Шаги реализации:**
1. `HomePage`: карточка "Сегодняшняя тренировка" + FAB "Быстрый старт". Соответствует `03_home.png`.
2. `ActiveWorkoutPage`: таймер, список упражнений, ввод set/reps/weight/RIR, кнопки "Следующий подход" / "Завершить". Соответствует `06_active_workout.png`.
3. `PostWorkoutSummaryPage`: итоги сессии (объём, PRs, время), кнопка "Сохранить". Соответствует `07_post_workout_summary.png`.

**Особенности реализации:**
- Таймер отдыха между подходами (Stopwatch/Timer).
- Сохранение черновика тренировки локально при каждом добавленном подходе (crash recovery).
- Поддержка offline: данные буферируются в Hive и синхронизируются при восстановлении сети.

---

### Сценарий 3: Плановая тренировка

```
Plan -> Workout Details -> Start -> Complete -> Progress update
```

**Экраны:** `plan_page`, `workout_details_page`, `active_workout_page`, `post_workout_summary_page`.

**Шаги реализации:**
1. `PlanPage`: недельный вид расписания (7 слотов), карточки запланированных тренировок. Соответствует `04_plan.png`.
2. `WorkoutDetailsPage`: список упражнений, рекомендованные веса, объяснение рекомендации. Соответствует `05_workout_details.png`.
3. Блок "Почему эта тренировка": краткое объяснение рекомендации (фраза от API).
4. CTA "Начать тренировку" -> `ActiveWorkoutPage`.

---

### Сценарий 4: Получение рекомендации

```
Home / Plan -> "Ввести текущее состояние" -> Рекомендация + объяснение
```

**Шаги реализации:**
1. Диалог/BottomSheet "Текущее состояние": поля (усталость 1–10, болезненность мышц 1–10, качество сна, частота сердцебиения).
2. Запрос к `POST /v1/recommendations/generate` с текущим состоянием.
3. Обновление карточки рекомендованной тренировки на `HomePage`.
4. Экран деталей тренировки отображает блок "Почему это рекомендовано сегодня".

---

### Сценарий 5: Отслеживание прогресса

```
Home -> Progress -> Filter period -> Drill-down metric
```

**Экраны:** `progress_page`.

**Шаги реализации:**
1. `ProgressPage`: дашборд с графиками (объём, частота тренировок, личные рекорды). Соответствует `08_progress.png`.
2. Фильтр периода: 7 / 30 / 90 дней.
3. `fl_chart`: линейные графики прогресса по весу/объёму, bar chart по неделям.
4. Карточки личных рекордов (PR) по упражнениям.

---

### Сценарий 6: Управление профилем и настройками

```
Profile -> Edit data -> Save -> Success feedback
```

**Экраны:** `profile_page`.

**Шаги реализации:**
1. `ProfilePage`: аватар, имя, цели, медицинские ограничения, настройки уведомлений. Соответствует `09_profile.png`.
2. Инлайн-редактирование или отдельный экран редактирования.
3. Сохранение с optimistic update + rollback при ошибке API.

---

### Сценарий 7: Управление базой упражнений

```
Workouts -> Exercise Library -> Add Exercise -> Save
```

**Экраны:** `exercise_library_page`, `add_exercise_page`.

**Шаги реализации:**
1. Список упражнений с поиском и фильтрацией по группе мышц.
2. Форма добавления упражнения: название, описание, группа мышц, оборудование, ограничения по здоровью.
3. Валидация формы перед отправкой.

---

### Сценарий 8: Негативные сценарии (Edge / Error States)

| Состояние | Экран | Поведение |
|-----------|-------|-----------|
| Нет тренировок | `10_empty_state.png` | Иллюстрация + CTA "Создать первую тренировку" |
| Нет сети | `11_offline_state.png` | Banner offline + показ кэшированных данных |
| Ошибка API | `12_api_error.png` | Error card + кнопка Retry |
| Timeout | inline | Snackbar + автоматический retry (3 попытки, exponential backoff) |
| Auth expired | auto | Silent token refresh; если не удалось — redirect на Sign In |

---

## Навигация (GoRouter)

```dart
// Основные маршруты
/                       -> redirect (auth check)
/welcome                -> WelcomePage
/sign-in                -> SignInPage
/onboarding/goals       -> GoalSelectionPage
/onboarding/metrics     -> PersonalMetricsPage
/onboarding/health      -> HealthLimitsPage

/home                   -> HomePage (shell route с BottomTabBar)
/home/plan              -> PlanPage
/home/plan/:workoutId   -> WorkoutDetailsPage
/home/workouts          -> ExerciseLibraryPage
/home/workouts/add      -> AddExercisePage
/home/progress          -> ProgressPage
/home/profile           -> ProfilePage

/workout/active         -> ActiveWorkoutPage  (fullscreen, без BottomTabBar)
/workout/summary        -> PostWorkoutSummaryPage
```

**Route guards:**
- `AuthGuard`: если токен отсутствует — redirect на `/welcome`.
- `OnboardingGuard`: если профиль не заполнен — redirect на `/onboarding/goals`.

---

## Сетевой слой и интеграция с API

### Базовая конфигурация Dio

```dart
// core/network/api_client.dart
final dio = Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,           // из .env / flutter_dotenv
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ),
)
  ..interceptors.add(AuthInterceptor(tokenRepository))
  ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
  ..interceptors.add(RetryInterceptor(retries: 3));
```

### Auth Interceptor

```dart
// core/network/auth_interceptor.dart
// При 401 -> refresh access token -> повтор запроса
// Если refresh не удался -> событие AuthExpired в AuthBloc -> redirect на Sign In
```

### API-сервисы (Retrofit)

Создать отдельный `@RestApi` интерфейс для каждого bounded context:

| Интерфейс | Prefix | Методы |
|-----------|--------|--------|
| `AuthApiService` | `/v1/auth` | `googleSignIn`, `refresh`, `signOut` |
| `ProfileApiService` | `/v1/profiles` | `getProfile`, `updateProfile` |
| `ExerciseApiService` | `/v1/exercises` | `list`, `create`, `get` |
| `ProgramApiService` | `/v1/programs` | `list`, `get`, `create` |
| `WorkoutSessionApiService` | `/v1/sessions` | `start`, `logSet`, `complete`, `history` |
| `RecommendationApiService` | `/v1/recommendations` | `generate`, `getExplanation` |
| `ProgressApiService` | `/v1/progress` | `getSummary`, `getMetrics` |

### Обработка ошибок

```dart
// core/error/failures.dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  ...
}
```

---

## Адаптивный интерфейс

Приложение ориентировано на **web с адаптивным layout**:

| Breakpoint | Layout |
|------------|--------|
| < 600 dp | Mobile: BottomTabBar, single column |
| 600–1024 dp | Tablet: NavigationRail, 2-column |
| > 1024 dp | Desktop: NavigationDrawer, 3-column |

```dart
// shared/widgets/adaptive_layout.dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return MobileLayout(child: child);
  if (width < 1024) return TabletLayout(child: child);
  return DesktopLayout(child: child);
}
```

---

## Локализация

- Основной язык: **русский** (`ru`).
- Дополнительный: **английский** (`en`).
- Использовать `flutter_localizations` + ARB-файлы (`lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`).
- Все пользовательские строки — только через `AppLocalizations.of(context)`.
- Форматирование дат и чисел через `intl`.

---

## Оффлайн-поддержка

1. **Токены** хранятся в `flutter_secure_storage`.
2. **Кэш данных** (список упражнений, программы, история) — в Hive.
3. **Черновик активной тренировки** — в Hive (ключ: `draft_session`), очищается после успешного сохранения.
4. **Connectivity check** через `connectivity_plus`; при потере сети — banner `OfflineBanner`.
5. **Sync queue** для pending set logs — буфер в Hive, отправляется при восстановлении сети.

---

## Безопасность

1. Access token — в памяти (не персистируется между сессиями).
2. Refresh token — в `flutter_secure_storage`.
3. Никаких чувствительных данных (token, личных данных) в логах.
4. HTTPS only (`--dart-define=API_BASE_URL=https://...`).
5. Certificate pinning — для production build (опционально, но задокументировать).
6. Медицинские предупреждения: при любых рекомендациях, связанных со здоровьем, показывать disclaimer "Не является медицинской консультацией".

---

## Тестирование

### Покрытие

| Тип | Приоритет | Инструменты |
|-----|-----------|-------------|
| Unit-тесты Use Cases | Высокий | `flutter_test`, `mocktail` |
| Unit-тесты BLoC/Cubit | Высокий | `bloc_test` |
| Unit-тесты Repository | Высокий | `mocktail` |
| Widget-тесты ключевых компонентов | Средний | `flutter_test` |
| Integration тесты ключевых сценариев | Средний | `integration_test` |
| Golden тесты компонентов | Низкий | `golden_toolkit` |

### Обязательные тесты (минимум)

- `AuthBloc`: Google Sign-In success / failure.
- `WorkoutSessionBloc`: старт, логирование подхода, завершение.
- `RecommendationCubit`: генерация рекомендации, ошибка API.
- `ProfileRepository`: получение и обновление профиля.
- `AuthInterceptor`: token refresh flow.

---

## Шаги реализации (очерёдность)

### Этап 1: Foundation
1. Инициализация Flutter проекта (`flutter create --platforms=web,ios,android`).
2. Настройка `pubspec.yaml` с зависимостями.
3. Реализация DI (`get_it` + `injectable`).
4. Реализация темы (`AppTheme`, `AppColors`, `AppTextStyles`, `AppSpacing`).
5. Настройка `GoRouter` с route guards.
6. Реализация сетевого слоя (`Dio`, `AuthInterceptor`, `RetryInterceptor`).

### Этап 2: Auth & Onboarding
7. `AuthBloc` + Google Sign-In.
8. `WelcomePage`, `SignInPage`.
9. Онбординг: `GoalSelectionPage`, `PersonalMetricsPage`, `HealthLimitsPage`.

### Этап 3: Core Screens
10. `AppShell` с `BottomTabBar` (5 табов).
11. `HomePage` с карточкой рекомендации и кнопкой быстрого старта.
12. `PlanPage` (недельный вид).
13. `WorkoutDetailsPage` с блоком объяснения рекомендации.
14. `ActiveWorkoutPage` (таймер, логирование подходов, crash recovery).
15. `PostWorkoutSummaryPage`.
16. `ProgressPage` с `fl_chart`.
17. `ProfilePage` с редактированием.
18. `ExerciseLibraryPage` + `AddExercisePage`.

### Этап 4: Shared Components & Polish
19. Компонентная библиотека (`AppButton`, `AppCard`, `AppInput`, и др.).
20. Адаптивный layout.
21. `EmptyStateWidget`, `ErrorStateWidget`, `OfflineBanner`.
22. Локализация (ru/en ARB).
23. Оффлайн-поддержка и sync queue.

### Этап 5: Testing
24. Unit-тесты Use Cases и BLoC.
25. Widget-тесты ключевых компонентов.
26. Integration-тесты ключевых сценариев.

---

## Критерии готовности (Definition of Done)

- [ ] Все 6 ключевых сценариев работают end-to-end (включая негативные ветки).
- [ ] Google Sign-In интегрирован и работает.
- [ ] Адаптивный layout корректно отображается при ширине < 600, 600–1024, > 1024 dp.
- [ ] Все ошибки API обрабатываются gracefully (с UI-feedback).
- [ ] Offline-режим: кэш доступен, sync queue работает.
- [ ] Черновик тренировки восстанавливается после закрытия вкладки/приложения.
- [ ] Рекомендации отображаются с объяснением.
- [ ] Медицинские предупреждения отображаются там, где это требуется.
- [ ] Все пользовательские строки локализованы (ru основной).
- [ ] Линтер (`flutter analyze`) не выдаёт ошибок.
- [ ] Минимальное тестовое покрытие: AuthBloc, WorkoutSessionBloc, RecommendationCubit.
- [ ] Приложение успешно собирается (`flutter build web`).

---

## Конфигурация окружения

Использовать `flutter_dotenv` или `--dart-define` для конфигурации:

```
API_BASE_URL=https://api.fitness-app.example.com
GOOGLE_CLIENT_ID=<your-client-id>
```

В CI/CD передавать через секреты. В репозитории хранить только `.env.example`.

---

## Рекомендуемые зависимости (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4

  # Navigation
  go_router: ^14.2.7

  # DI
  get_it: ^8.0.0
  injectable: ^2.4.4

  # Networking
  dio: ^5.7.0
  retrofit: ^4.1.0
  pretty_dio_logger: ^1.4.0

  # Auth
  google_sign_in: ^6.2.1

  # Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Storage
  flutter_secure_storage: ^9.2.2
  hive_flutter: ^1.1.0

  # UI / Charts
  fl_chart: ^0.69.0

  # Connectivity
  connectivity_plus: ^6.0.5

  # Utils
  flutter_dotenv: ^5.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  injectable_generator: ^2.6.2
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  retrofit_generator: ^8.1.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
```

---

## Артефакты для возврата

1. Полный исходный код Flutter-приложения в директории `flutter_app/`.
2. `pubspec.yaml` с зафиксированными версиями зависимостей.
3. `.env.example` с перечнем необходимых переменных окружения.
4. Инструкция по запуску (`flutter_app/README.md`): установка зависимостей, запуск web, запуск тестов.
5. Таблица соответствия: сценарий -> экраны -> BLoC -> API endpoint.
6. Список известных ограничений и допущений.
7. Список нерешённых вопросов (если есть gap между требованиями и возможностями API).
