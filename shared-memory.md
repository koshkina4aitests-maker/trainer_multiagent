# Shared Memory

## Current iteration
- `iteration_id`: `iter-01`
- `owner`: `Technical PM`
- `global_status`: `in_progress`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter01.md`
- `status`: `done`
- `notes`: Основные замечания собраны, приоритеты выставлены.

## Business Analyst -> Architect
- `input`: `requirements-iter01.md`
- `status`: `done`
- `notes`: UX-замечания переведены в требования + acceptance criteria.

## Architect -> Backend/Frontend
- `input`: `architecture-iter01.md`
- `status`: `done`
- `notes`: Определены API-контракты, data model, NFR и риски.

## Frontend + Designer
- `input`: `frontend-design-iter01.md`
- `status`: `done`
- `notes`: Обновлены интерактивные UX-решения для проблемных экранов.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter01.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter01.md`
  - `ready_for_pipeline`: `ok`

## DevOps secrets policy
- `ssh_password_requested`: `done`
- `ssh_password_storage`: `forbidden`
- `post_use_cleanup`: `done`

## DevOps -> UX final regression
- `input`: `devops-pipeline-iter01.md`
- `pipeline_status`: `passed`
- `status`: `done`
- `notes`: Финальный UX-прогон выполнен, замечания опубликованы.

## Iteration close
- `final_ux_artifact`: `ux-final-iter01.md`
- `global_status`: `completed`

