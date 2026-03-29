# APK Debug Build Report — iter-04

## Source
- Reference branch used for Flutter app build:
  - `origin/cursor/-bc-fb6959b5-7b03-49f1-b6df-cba7dc04caf5-ad0c`
- Build workspace:
  - isolated worktree under `/workspace/.worktrees/flutter-apk-debug/flutter_app`

## Build mode
- Target: `debug`
- Command:
  - `flutter build apk --debug`
- Signing:
  - default Android debug keystore (no custom signing key required)

## Compatibility note
- A temporary local `pubspec_overrides.yaml` was used in isolated build workspace:
  - `intl: 0.19.0`
- This override was used only to satisfy SDK dependency pinning in this environment and was not committed into source branch.

## Artifact
- Output copied to:
  - `/workspace/fitness_app-debug-iter04.apk`
- File size:
  - ~90 MB

## Status
- `apk_debug_build_status=passed`
- `artifact=fitness_app-debug-iter04.apk`
