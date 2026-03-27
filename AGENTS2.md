# AGENTS2: Архитектура Fitness App

Роль: **Senior Solution Architect**

Документ описывает целевую архитектуру fitness-приложения на основе проработанных продуктовых требований из агента **Fitness app requirements**.

---

## 1) Цели и архитектурные драйверы

### Продуктовые цели
- Персональные планы тренировок и питания.
- Трекинг активности, прогресса, привычек и целей.
- Удержание пользователя через напоминания, геймификацию и челленджи.
- Масштабируемость под рост пользователей и интеграций (wearables, платежи, контент).

### Ключевые драйверы архитектуры
- **Mobile-first** UX (iOS/Android, быстрые отклики API).
- **Надежность**: высокая доступность критичных функций (логин, план, трекинг, платежи).
- **Data-driven**: сбор событий и аналитика для персонализации.
- **Безопасность и приватность**: защита персональных и health-related данных.
- **Эволюционность**: возможность стартовать быстро и постепенно переходить к более модульной архитектуре.

---

## 2) Предлагаемая high-level архитектура

Рекомендуемый подход: **модульный монолит с четкими bounded contexts** на старте, с готовностью к выделению отдельных сервисов по мере нагрузки.

### Почему не сразу микросервисы
- Быстрее time-to-market.
- Ниже операционная сложность для команды.
- Домен fitness-продукта хорошо раскладывается на модули внутри одного codebase.

### Когда выделять в отдельные сервисы
- Отдельные профили нагрузки (например, Analytics/Recommendations/Notifications).
- Независимый lifecycle и масштабирование.
- Интеграционные требования (например, Billing/Payments с повышенными требованиями к аудиту).

---

## 3) Контекстная схема (уровень C4-Context)

**Клиенты:**
- Mobile App (iOS/Android)
- Web Admin / Coach Portal

**Backend Platform:**
- API Backend (BFF + Domain modules)
- Background Workers (jobs, notification scheduler, sync tasks)
- Event Pipeline (event bus + analytics ingestion)

**Внешние системы:**
- Auth Provider (OIDC/social login)
- Payment provider (подписки, чеки, вебхуки)
- Push provider (APNS/FCM)
- Email/SMS provider
- Wearables/Health APIs (Apple Health, Google Fit, Garmin/Fitbit при необходимости)

---

## 4) Доменная декомпозиция (bounded contexts)

1. **Identity & Access**
   - Регистрация, вход, refresh, MFA (опционально), роли.

2. **User Profile & Goals**
   - Анкета, ограничения по здоровью, цели (похудение/сила/выносливость), предпочтения.

3. **Training Program**
   - Библиотека упражнений, генерация/настройка плана, расписание тренировок.

4. **Workout Tracking**
   - Логи сессий, подходы/повторы/вес/пульс, завершение тренировки, PR.

5. **Nutrition**
   - План питания, дневник питания, цели по калориям/БЖУ, базовые рекомендации.

6. **Progress & Insights**
   - Метрики прогресса, графики, weekly/monthly отчеты, базовые инсайты.

7. **Engagement**
   - Напоминания, streaks, достижения, челленджи.

8. **Subscription & Billing**
   - Тарифы, подписка, статусы доступа, обработка вебхуков платежей.

9. **Content Management**
   - Медиа/уроки/статьи, версии контента, теги, локализация.

10. **Analytics & Experimentation**
    - События продукта, воронки, cohort retention, A/B тесты.

---

## 5) Техническая структура backend

## API слой
- **REST API** как основной контракт для mobile.
- Опционально **GraphQL** для сложных экранов/агрегаций.
- Версионирование (`/v1`), строгие DTO, idempotency для критичных write-операций.

## Application слой
- Use-cases / services по доменам.
- Валидация команд, orchestration бизнес-операций, транзакционные границы.

## Domain слой
- Сущности, value objects, доменные правила.
- Минимум инфраструктурных зависимостей в домене.

## Infrastructure слой
- Репозитории, интеграции (payments, push, wearables), event publisher/consumer.

## Async jobs
- Очереди для:
  - отправки уведомлений,
  - синхронизации wearables,
  - пересчета прогресса и генерации инсайтов,
  - обработки платежных вебхуков.

---

## 6) Данные и хранилища

### Основная OLTP БД
- **PostgreSQL**:
  - users, profiles, goals
  - programs, exercises, workout_sessions
  - nutrition_logs
  - subscriptions, billing_events

### Кэш и быстрые структуры
- **Redis**:
  - session/cache,
  - rate limiting,
  - short-lived personalization context.

### Аналитика
- Event stream -> аналитическое хранилище (например, ClickHouse/BigQuery/Snowflake в зависимости от облака и бюджета).
- Разделение operational vs analytical workloads.

### Хранилище файлов
- Объектное хранилище (S3-compatible) для медиа/аватаров/видео.

---

## 7) Основные интеграционные сценарии

1. **User onboarding**
   - Auth -> profile setup -> goals -> план тренировок/питания -> расписание.

2. **Workout session flow**
   - Получить план -> начать тренировку -> логировать подходы -> завершить -> пересчитать прогресс -> отправить мотивационное сообщение.

3. **Billing flow**
   - Инициация подписки -> подтверждение провайдером -> webhook -> обновление entitlements -> аудит события.

4. **Wearable sync flow**
   - Pull/push активности -> дедупликация -> нормализация -> обновление дневника активности.

---

## 8) Нефункциональные требования (NFR)

### Производительность
- P95 API latency:
  - read <= 300 ms,
  - write <= 500 ms (без тяжелых синхронных интеграций).

### Доступность
- SLA backend API: 99.9% (критичный контур).
- Graceful degradation для вторичных функций (например, delayed insights).

### Масштабирование
- Горизонтальное масштабирование stateless API.
- Отдельное масштабирование worker pool и очередей.

### Наблюдаемость
- Structured logs, metrics, traces.
- Бизнес-метрики: activation, WAU/MAU, retention, plan completion, churn.

---

## 9) Безопасность и compliance

- OAuth2/OIDC, короткоживущие access tokens, refresh rotation.
- Шифрование in transit (TLS 1.2+) и at rest.
- RBAC для Admin/Coach/Support зон.
- Secret management через vault/managed secrets.
- Аудит критичных действий (billing, role changes, data export/delete).
- Data retention policy и удаление пользовательских данных по запросу.

---

## 10) CI/CD и окружения

### Environments
- `dev` -> `staging` -> `prod`.

### Delivery
- Trunk-based development с короткоживущими ветками.
- Автотесты: unit + integration + contract tests.
- Миграции БД с backward-compatible стратегией.
- Blue/Green или Canary деплой для backend.

### Quality gates
- Lint + type checks + tests + security scan (SAST/dependency scan).

---

## 11) Эволюционный план архитектуры

## Этап 1 (MVP)
- Модульный монолит, PostgreSQL, Redis, очередь jobs.
- Core-модули: Identity, Profile/Goals, Training, Tracking, Billing Lite, Notifications.

## Этап 2 (Growth)
- Выделение Analytics pipeline.
- Расширение Recommendation engine.
- Улучшение персонализации и A/B platform.

## Этап 3 (Scale)
- При необходимости выделить отдельные сервисы:
  - Notifications,
  - Billing,
  - Recommendations/Insights.
- Усилить multi-region/DR стратегию.

---

## 12) Риски и меры

- **Риск:** высокая связность доменов при быстром росте фич.  
  **Мера:** явные контракты модулей, domain events, архитектурные ревью.

- **Риск:** сложность интеграций wearables.  
  **Мера:** адаптерный слой + retry/idempotency + нормализация данных.

- **Риск:** неточности персонализации на ранних данных.  
  **Мера:** rule-based baseline + постепенный rollout ML.

- **Риск:** billing edge-cases (webhook delays/duplicates).  
  **Мера:** event sourcing-lite журнал billing_events и идемпотентная обработка.

---

## 13) Рекомендуемый стартовый tech stack (пример)

- **Mobile:** Flutter или React Native (при одной команде), нативные интеграции для health APIs.
- **Backend:** TypeScript (NestJS) / Kotlin (Spring Boot) / Python (FastAPI) — выбрать стек команды.
- **DB:** PostgreSQL
- **Cache/queue:** Redis + BullMQ/Celery/RQ (в зависимости от языка)
- **Infra:** Docker + managed Kubernetes (или serverless containers для старта)
- **Observability:** OpenTelemetry + Prometheus/Grafana + centralized logs

---

## 14) Результат для команды

Эта архитектура обеспечивает:
- быстрый старт без преждевременной микросервисной сложности;
- понятное масштабирование по доменным границам;
- фундамент для персонализации, аналитики и роста монетизации;
- управляемые риски безопасности и надежности для fitness-продукта.
