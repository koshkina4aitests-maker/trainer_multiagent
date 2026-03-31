# APK Build Report — iter-06

## Scope
- branch: `cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
- app: `flutter_app`
- target artifact: release APK

## Toolchain
- Flutter SDK: `/workspace/flutter-sdk` (installed locally for this run)
- Android SDK: `/workspace/android-sdk` (installed locally for this run)
- Java: OpenJDK 21

## Validation before build
- `flutter pub get` — passed
- `flutter analyze` — passed
- `flutter test` — passed

## Build
- command:
  - `/workspace/flutter-sdk/bin/flutter build apk --release --android-skip-build-dependency-validation`
- result: passed
- output:
  - `flutter_app/build/app/outputs/flutter-apk/app-release.apk`
- copied artifact:
  - `fitness_app-release-iter06.apk`
- checksum (sha256):
  - `7d63cb0d8bec6fb1d7593b99d0871e7c4b06074b58388ee9822854fc7e9af418`

## Notes
- Android Gradle and Kotlin plugin versions were updated in project config to restore build compatibility with current Flutter toolchain.
- Local SDK folders (`flutter-sdk/`, `android-sdk/`) are ignored in git and not included in repository contents.
