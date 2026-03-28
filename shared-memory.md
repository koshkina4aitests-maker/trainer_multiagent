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

---

## Current iteration
- `iteration_id`: `iter-02`
- `owner`: `Technical PM`
- `global_status`: `completed`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter02.md`
- `status`: `done`
- `notes`: Входом стали остаточные замечания из финального UX iter-01.

## Business Analyst -> Architect
- `input`: `requirements-iter02.md`
- `status`: `done`
- `notes`: Сформированы требования для объяснения интенсивности и увеличения tap-target.

## Architect -> Backend/Frontend
- `input`: `architecture-iter02.md`
- `status`: `done`
- `notes`: Уточнены API/контракты и ограничения UI для изменений iter-02.

## Frontend + Designer
- `input`: `frontend-design-iter02.md`
- `status`: `done`
- `notes`: Переданы UI-инварианты для helper copy и hitbox 44px.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter02.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter02.md`
  - `ready_for_pipeline`: `ok`

## DevOps secrets policy
- `ssh_password_requested`: `done`
- `ssh_password_storage`: `forbidden`
- `post_use_cleanup`: `done`

## DevOps -> UX final regression
- `input`: `devops-pipeline-iter02.md`
- `pipeline_status`: `passed`
- `status`: `done`
- `notes`: Финальный UX-прогон iter-02 завершен без блокирующих замечаний.

## Iteration close
- `final_ux_artifact`: `ux-final-iter02.md`
- `global_status`: `completed`

---

## Current iteration
- `iteration_id`: `iter-02`
- `owner`: `Technical PM`
- `global_status`: `in_progress`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter02.md`
- `status`: `done`
- `notes`: Вход собран из non-blocking замечаний предыдущего финального UX-прогона.

## Business Analyst -> Architect
- `input`: `requirements-iter02.md`
- `status`: `done`
- `notes`: Сформированы требования по объяснению интенсивности и размеру tap target.

## Architect -> Backend/Frontend
- `input`: `architecture-iter02.md`
- `status`: `done`
- `notes`: Обновлены API-поля рекомендации и UI-контракт по hit area.

## Frontend + Designer
- `input`: `frontend-design-iter02.md`
- `status`: `done`
- `notes`: Подготовлены токены и прототипные правила под 44px touch target.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter02.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter02.md`
  - `ready_for_pipeline`: `ok`

## DevOps secrets policy
- `ssh_password_requested`: `pending`
- `ssh_password_storage`: `forbidden`
- `post_use_cleanup`: `required`

