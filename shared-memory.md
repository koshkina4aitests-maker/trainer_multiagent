# Shared Memory

## Current iteration
- `iteration_id`: `iter-04`
- `owner`: `Technical PM`
- `global_status`: `in_progress`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter04.md`
- `status`: `done`
- `notes`: Вход собран из non-blocking замечаний финального UX прогона iter-03.

## Business Analyst -> Architect
- `input`: `requirements-iter04.md`
- `status`: `done`
- `notes`: Сформированы требования по coach hints при промахе целей и по weekly annotation sleep-vs-performance.

## Architect -> Backend/Frontend
- `input`: `architecture-iter04.md`
- `status`: `done`
- `notes`: Уточнены API/данные и UI-контракты для coach hints и тренд-аннотаций.

## Frontend + Designer
- `input`: `frontend-design-iter04.md`
- `status`: `done`
- `notes`: Подготовлены UX-правила для hint badges и weekly trend annotation.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter04.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter04.md`
  - `ready_for_pipeline`: `ok`

## DevOps secrets policy
- `ssh_password_requested`: `done`
- `ssh_password_storage`: `forbidden`
- `post_use_cleanup`: `done`

## DevOps deployment stage
- `preflight_status`: `done`
- `status`: `blocked`
- `notes`: SSH/password authentication succeeded and host preflight passed, but deploy was blocked by branch mismatch: deployment branch (`cursor/-bc-...`) does not contain runtime backend stack files (`docker-compose.yml`), while server runtime uses `cursor/backend-548e`.
- `next_action`: Get explicit deployment target branch/tag for backend (or merge runtime changes into deploy branch), then re-run `docker compose up -d --build` on the correct branch.

