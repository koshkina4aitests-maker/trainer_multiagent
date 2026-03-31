# Google Auth Upgrade Report — iter-08

## Scope
- Replace demo Google login with real Google OAuth ID token flow.
- Validate Google ID tokens on backend and persist authenticated user session on mobile/web app.

## Backend changes
- `app/schemas/auth.py`
  - request contract changed to:
    - `id_token` (required)
- `app/services/google_auth.py`
  - added Google token verification service using `google-auth`
  - validates:
    - token signature/issuer via Google certs
    - audience against configured client IDs
    - required claims (`sub`, `email`)
  - returns normalized `GoogleIdentity`
- `app/services/auth_service.py`
  - `/v1/auth/google` now uses verified identity from token claims
  - user upsert is based on verified `google_sub`
- `app/core/config.py`
  - added `google_oauth_client_ids` as comma-separated config (`FITNESS_GOOGLE_OAUTH_CLIENT_IDS`)
- `pyproject.toml`
  - added dependency: `google-auth`

## Flutter changes
- Added real auth data path:
  - `flutter_app/lib/features/auth/data/datasources/auth_remote_datasource.dart`
  - `flutter_app/lib/features/auth/data/models/google_auth_payload.dart`
  - `flutter_app/lib/features/auth/data/models/auth_response.dart`
  - `flutter_app/lib/core/config/app_config.dart`
- Integrated `google_sign_in` package in repository/DI:
  - `flutter_app/lib/features/auth/data/repositories/auth_repository_impl.dart`
  - `flutter_app/lib/core/di/service_locator.dart`
  - `flutter_app/pubspec.yaml`
- Sign-in UI now triggers Google OAuth flow event consistently:
  - `flutter_app/lib/features/auth/presentation/pages/welcome_page.dart`
  - `flutter_app/lib/features/auth/presentation/pages/sign_in_page.dart`
- Local auth storage extended for `google_sub` persistence:
  - `flutter_app/lib/core/storage/local_storage.dart`
  - `flutter_app/lib/features/auth/data/datasources/auth_local_datasource.dart`

## Test adaptation
- `tests/test_api_flow.py`
  - auth step updated to `id_token` payload
  - Google verification mocked in test (`verify_google_id_token`) to keep tests deterministic/offline.

## Validation
- `python3 -m pytest -q` ✅
- `flutter analyze` ✅
- `flutter test` ✅

## Runtime config requirements
- Backend env:
  - `FITNESS_GOOGLE_OAUTH_CLIENT_IDS=<client_id_1>,<client_id_2>`
- Flutter run/build:
  - `--dart-define=API_BASE_URL=http://<backend-host>:8000`
  - optional for web oauth compatibility:
    - `--dart-define=GOOGLE_WEB_CLIENT_ID=<google-web-client-id>`
