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

## APK debug packaging
- `source_branch`: `cursor/-bc-fb6959b5-7b03-49f1-b6df-cba7dc04caf5-ad0c`
- `apk_debug_build_status`: `passed`
- `artifact`: `fitness_app-debug-iter04.apk`
- `notes`: Debug APK assembled without signing key (`flutter build apk --debug`) in isolated build environment.

