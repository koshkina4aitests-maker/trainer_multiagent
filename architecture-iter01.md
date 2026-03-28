# Fitness app architecture — Iteration 01

## 1. Scope
- User onboarding/profile
- Workout catalog and session logging
- Calendar sync and reminders
- Progress dashboard

## 2. High-level components
- **Frontend (Web/Mobile UI)**
  - Screens: Onboarding, Dashboard, Workout Detail, Session Complete, Progress
  - State domains: auth/profile, workouts, sessions, progress
- **Backend API**
  - Auth/Profile service
  - Workout Catalog service
  - Session Tracking service
  - Progress/Analytics service
- **Data layer**
  - Relational DB for users/workouts/sessions
  - Cache for dashboard aggregates

## 3. API contracts (v1)
- `GET /api/v1/workouts?goal={goal}&level={level}`
- `POST /api/v1/sessions`
  - body: `user_id, workout_id, started_at, finished_at, calories, rpe`
- `GET /api/v1/progress/summary?user_id={id}&range={7d|30d|90d}`
- `PATCH /api/v1/profile/{user_id}`

## 4. Data model updates
- `users` (id, timezone, goals, fitness_level)
- `workouts` (id, category, duration_min, level, equipment_required)
- `sessions` (id, user_id, workout_id, started_at, finished_at, calories, rpe)
- `daily_progress` (user_id, date, active_minutes, calories, streak_day)

## 5. NFR and constraints
- Dashboard p95 latency < 700ms for summary endpoint
- Uptime target 99.9%
- Event timestamps always stored in UTC
- API backward-compatible for mobile clients

## 6. Handoff package to developers
- Input requirements: `requirements-iter01.md`
- UX source: `ux-report-iter01.md`
- This architecture artifact as the source of API/data contracts
