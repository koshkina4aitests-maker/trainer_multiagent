# Fitness App Backend (MVP)

Python backend для fitness-приложения, реализованный как **modular monolith** по архитектуре из `AGENTS2`.

## Стек

- FastAPI
- SQLAlchemy 2.x
- Pydantic v2
- Celery + Redis (для async jobs)

## Реализованные контексты MVP

- Identity (`POST /v1/auth/google`)
- User Profile & Goals
- Training Program (упражнения + планы)
- Workout Tracking (сессии, логи, история)
- Explainable Recommendations
- Safety Screening (risk/warnings/emergency guidance)

## API

- `GET /health`
- Документация OpenAPI: `GET /v1/docs`

Основные роуты:

- `POST /v1/auth/google`
- `PUT /v1/users/{user_id}/profile`
- `POST /v1/users/{user_id}/goals`
- `POST /v1/exercises`
- `GET /v1/exercises`
- `POST /v1/users/{user_id}/plans`
- `GET /v1/users/{user_id}/plans`
- `POST /v1/workouts/sessions`
- `POST /v1/workouts/sessions/{session_id}/logs`
- `POST /v1/workouts/sessions/{session_id}/complete`
- `GET /v1/workouts/history/{user_id}`
- `POST /v1/users/{user_id}/recommendations`
- `POST /v1/safety/screening`

## Локальный запуск

```bash
python3 -m pip install -e .[dev]
python3 -m uvicorn app.main:app --reload
```

## Тесты

```bash
python3 -m pytest -q
```