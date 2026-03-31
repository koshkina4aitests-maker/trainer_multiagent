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
- `iteration_id`: `iter-06`
- `owner`: `Technical PM`
- `global_status`: `completed`

## UX Tester -> Business Analyst
- `input`: `ux-report-iter05.md` + user confirmation to execute full cycle
- `status`: `done`
- `notes`: Подтвержден запуск полного цикла с реализацией profile/recommendation/plan обновлений.

## Business Analyst -> Architect
- `input`: `requirements-iter05.md`
- `status`: `done`
- `notes`: Требования зафиксированы и доведены до имплементации и валидации.

## Architect -> Backend/Frontend
- `input`: `architecture-iter05.md`
- `status`: `done`
- `notes`: Контракты синхронизированы между backend и Flutter.

## Development readiness
- backend:
  - `artifact`: `backend-status-iter05.md`
  - `ready_for_pipeline`: `ok`
- frontend:
  - `artifact`: `frontend-status-iter05.md`
  - `ready_for_pipeline`: `ok`

## DevOps pipeline and verification
- `pipeline_status`: `passed`
- `backend_tests`: `passed` (`python3 -m pytest -q`)
- `flutter_analyze`: `passed`
- `flutter_tests`: `passed`
- `apk_build_status`: `passed`
- `apk_artifact`: `fitness_app-release-iter06.apk`
- `apk_report`: `apk-build-iter06.md`

## DevOps deployment stage
- `ssh_password_requested`: `done`
- `ssh_password_storage`: `forbidden`
- `post_use_cleanup`: `done`
- `status`: `done`
- `artifact`: `devops-deploy-iter06.md`
- `notes`: Backend deployed on `/opt/fitness-app` with source branch `cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`; API health `ok`, worker restored to `healthy` via runtime compose override on server.

## UX final regression (iter-06)
- `input`: `fitness_app-release-iter06.apk`, deployment/runtime verification
- `status`: `done`
- `artifact`: `ux-final-iter06.md`
- `verdict`: `passed_with_non_blocking_notes`
- `notes`: Функциональные требования iter-06 закрыты, замечания носят polish-характер.

## UX strict audit (iter-06, max strict)
- `input`: `fitness_app-release-iter06.apk`, source review for UX-critical paths
- `status`: `done`
- `artifact`: `ux-strict-iter06.md`
- `verdict`: `failed_with_blockers`
- `notes`: Выявлены критичные UX-риски в core-flow рекомендаций/плана (несоответствие запуска рекомендованной тренировки фактическому составу упражнений, silent failure и навигационные сбои). Требуется corrective iteration.

## Corrective iteration for strict UX blockers (iter-06)
- `status`: `done`
- `source_commit`: `7597e34`
- `changes`:
  - recommendation start flow now passes normalized exercise ids/names
  - recommendation card shows sets/reps/weight/RIR preview
  - plan add form now shows explicit snackbar feedback on invalid save attempts
  - workout edit save closes only editor sheet (no extra back navigation)
  - requirement and architecture artifacts updated with web frontend parity requirement
- `artifact`: `ux-retest-iter06-blockers.md`
- `verdict`: `blockers_closed_code_review`
- `notes`: Блокеры из strict UX-аудита закрыты на уровне реализованных code-path. Требуется следующий device-level regression pass для финального release sign-off.

## Web parity implementation (iter-06b)
- `status`: `done`
- `scope`: frontend web behavior parity for mobile core flows
- `artifact`: `frontend-web-parity-iter06b.md`
- `changes`:
  - adaptive app shell with `NavigationRail` on wide layouts and mobile bottom navigation on compact layouts
  - responsive content widths for Home / Plan / Profile / Active Workout / Post Workout Summary pages
  - preserved domain/business behavior parity for recommendation, plan and workout flows
- `validation`:
  - `flutter analyze`: passed
  - `flutter test`: passed
  - `python3 -m pytest -q`: passed
- `notes`: Реализован web-friendly layout без изменения бизнес-правил мобильного UX.

## Final release cycle (iter-06c)
- `status`: `done`
- `artifacts`:
  - `apk-build-iter06c.md`
  - `web-build-iter06c.md`
  - `devops-deploy-iter06c.md`
  - `ux-final-iter06c.md`
  - `devops-web-port-iter06c.md`
- `mobile_release_apk`: `fitness_app-release-iter06c.apk`
- `web_release_bundle`: `fitness_app-web-iter06c.tar.gz` (deployed to `/opt/fitness-app/web_build`)
- `web_runtime_publish`:
  - service: `nginx` via `docker-compose.web.yml`
  - port: `8080`
  - url: `http://95.81.124.133:8080`
- `deployment`:
  - backend branch deployed: `cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
  - API health: `ok`
  - worker health: `healthy`
- `final_signoff`:
  - mobile+web release candidate accepted for current scope
  - no blocking issues in final technical UX sign-off

## Next cycle requirement intake (iter-07)
- `status`: `in_progress`
- `requirement_delta`:
  - fix design in planned workout edit form so field labels are fully visible
- `implementation`:
  - updated `flutter_app/lib/features/plan/presentation/pages/workout_details_page.dart`
  - replaced single-row 4-field layout with adaptive layout:
    - narrow sheets: 2x2 grid (two rows)
    - wide sheets: 4 fields in one row
  - expanded labels from short abbreviations to full labels (`Подходы`, `Повторы`, `Вес (кг)`, `RIR`)
  - set numeric field labels to always float for better readability
- `validation`:
  - `flutter analyze`: passed
  - `flutter test`: passed
- `ux_retest_artifact`: `ux-retest-iter07-plan-edit-layout.md`

## Next cycle requirement intake (iter-07b)
- `status`: `in_progress`
- `requirement_delta`:
  - allow adding/removing exercises in recommendation-based planned workouts
  - allow per-set configuration (different reps/weight/RIR for each set)
- `implementation`:
  - domain model extended:
    - added `PlannedSetDetail` for per-set targets
    - `PlannedExerciseDetail` now stores `setDetails` with backward-compatible normalization
  - workout editor upgraded in `workout_details_page.dart`:
    - add/remove exercise controls in edit sheet
    - editable exercise name per row
    - per-set editor: add/remove set and edit reps/weight/RIR for each set
    - validation blocks save when all exercise names are empty
- `validation`:
  - `flutter analyze`: passed
  - `flutter test`: passed
- `ux_retest_artifact`: `ux-retest-iter07-plan-editor-sets.md`

## Next cycle requirement intake (iter-08)
- `status`: `in_progress`
- `requirement_delta`:
  - implement production-grade Google authentication flow
- `implementation`:
  - backend:
    - switched `/v1/auth/google` request payload to `id_token`
    - added Google ID token verification service (`app/services/google_auth.py`)
    - validates token audience against configured OAuth client IDs
    - auth service now upserts user from verified token claims (`sub`, `email`, `name`)
    - dev/test bypass supported with `FITNESS_GOOGLE_AUTH_ALLOW_FAKE=true`
  - flutter:
    - integrated `google_sign_in` and backend auth call via `http`
    - added API config (`API_BASE_URL`, `GOOGLE_WEB_CLIENT_ID`) in `app_config.dart`
    - auth repository now obtains Google `idToken` and exchanges it with backend
    - updated DI for `GoogleSignIn`, remote datasource, and HTTP client
    - auth events/UI wired to real sign-in flow
  - tests:
    - backend integration test updated to monkeypatch token verification and use `id_token`
    - auth bloc tests adapted to updated sign-in event contract
- `validation`:
  - `python3 -m pytest -q`: passed
  - `flutter analyze`: passed
  - `flutter test`: passed
- `artifact`: `auth-google-iter08.md`

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

