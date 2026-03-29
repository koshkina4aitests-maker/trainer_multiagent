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
- `status`: `done`
- `notes`: Deployment executed on runtime branch `cursor/backend-548e`; worker healthcheck fixed to Celery-native probe (`celery inspect ping -d celery@$$HOSTNAME`). Full stack now healthy (`api`, `redis`, `worker`) and API health endpoint returns `ok`.
- `next_action`: Proceed to UX final regression for iter-04 release candidate.

## APK build and release packaging
- `source_branch`: `cursor/-bc-fb6959b5-7b03-49f1-b6df-cba7dc04caf5-ad0c`
- `analyze_status`: `passed`
- `test_status`: `passed`
- `apk_build_status`: `passed`
- `artifact`: `fitness_app-release-iter04.apk`
- `notes`: APK built in isolated worktree using local Flutter/Android toolchain with temporary `pubspec_overrides.yaml` (`intl: 0.19.0`) for SDK compatibility during CI build.

## UX final regression (iter-04)
- `input`: `fitness_app-release-iter04.apk`, `fitness_app-debug-iter04.apk`
- `status`: `done`
- `artifact`: `ux-final-iter04.md`
- `verdict`: `passed_with_non_blocking_gaps`
- `notes`: Улучшения iter-02 подтверждены (интенсивность + helper copy + 44px tap targets + переходы в детали тренировки). Критичные UX-проблемы 1,2,3,5,6,7 из UX-ветки не входят в текущую APK-сборку и остаются в бэклоге следующих итераций.

## APK debug packaging
- `source_branch`: `cursor/-bc-fb6959b5-7b03-49f1-b6df-cba7dc04caf5-ad0c`
- `apk_debug_build_status`: `passed`
- `artifact`: `fitness_app-debug-iter04.apk`
- `notes`: Debug APK assembled without signing key (`flutter build apk --debug`) in isolated build environment.

---

## Current iteration
- `iteration_id`: `iter-05`
- `owner`: `Technical PM`
- `global_status`: `completed`

## Requirements intake
- `input`: user-provided requirements (profile + recommendations + plan upgrades)
- `status`: `done`
- `notes`: Новые требования формализованы и проведены через полный цикл.

## Business Analyst -> Architect
- `input`: `requirements-iter05.md`
- `status`: `done`
- `notes`: Требования по профилю, рекомендациям и плану детализированы с acceptance criteria.

## Architect -> Backend/Frontend
- `input`: `architecture-iter05.md`
- `status`: `done`
- `notes`: Обновлены API-контракты, data model и UI/flow constraints.

## Frontend + Designer
- `input`: `frontend-design-iter05.md`
- `status`: `done`
- `notes`: Подготовлены UX-спеки и интерактивные flow-обновления.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter05.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter05.md`
  - `ready_for_pipeline`: `ok`

## DevOps pipeline and deployment
- `pipeline_artifact`: `devops-pipeline-iter05.md`
- `deploy_artifact`: `devops-deploy-iter05.md`
- `pipeline_status`: `passed`
- `deploy_status`: `done`
- `notes`: SSH/password preflight passed; server deployment executed on `/opt/fitness-app` (`cursor/backend-548e`), `docker compose up -d --build` completed, services healthy, `/health` returned `ok`.

## APK build
- `artifact`: `fitness_app-release-iter05.apk`
- `apk_build_status`: `passed`
- `notes`: Release APK assembled from source branch `cursor/-bc-fb6959b5-7b03-49f1-b6df-cba7dc04caf5-ad0c`.

## UX final regression
- `artifact`: `ux-final-iter05.md`
- `status`: `done`
- `verdict`: `passed_with_non_blocking_issues`
- `notes`: Основные требования покрыты; замечания перенесены в backlog.

---

## Current iteration
- `iteration_id`: `iter-05`
- `owner`: `Technical PM`
- `global_status`: `completed`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter05.md`
- `status`: `done`
- `notes`: Новые требования от заказчика конвертированы в UX-вход по 3 ключевым блокам (Профиль, Рекомендации, План).

## Business Analyst -> Architect
- `input`: `requirements-iter05.md`
- `status`: `done`
- `notes`: Сформированы must/should требования и acceptance criteria для всех новых фич.

## Architect -> Backend/Frontend
- `input`: `architecture-iter05.md`
- `status`: `done`
- `notes`: Уточнены модель данных, API-контракты и сценарии копирования/редактирования рекомендованных тренировок.

## Frontend + Designer
- `input`: `frontend-design-iter05.md`
- `status`: `done`
- `notes`: Подготовлены UX-правила: поля в плане (sets/reps/weight/RIR), умный поиск упражнений и стиль рекомендаций.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter05.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter05.md`
  - `ready_for_pipeline`: `ok`

## DevOps pipeline + UX closure
- `pipeline_artifact`: `devops-pipeline-iter05.md`
- `pipeline_status`: `passed`
- `ux_final_artifact`: `ux-final-iter05.md`
- `ux_status`: `done`
- `notes`: Регрессия по новым требованиям пройдена, блокирующих замечаний нет.

