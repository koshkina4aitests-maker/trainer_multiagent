# FitApp — Flutter Frontend

Fitness tracking and recommendation app built with Flutter.

## Prerequisites

- Flutter SDK 3.29+ (`flutter --version`)
- Android SDK (for APK build)
- Java 11+

## Setup

```bash
cd flutter_app
flutter pub get
```

## Run

```bash
# Web
flutter run -d chrome

# Android (debug)
flutter run -d android

# Android release APK
flutter build apk --release
```

## Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Test

```bash
flutter test
flutter analyze
```

## Architecture

Clean Architecture with BLoC state management:

```
data → domain → presentation
```

| Layer | Responsibility |
|-------|---------------|
| domain/entities | Pure Dart data models |
| domain/repositories | Abstract interfaces |
| domain/usecases | Single-responsibility use cases |
| data/datasources | Local storage (SharedPreferences) |
| data/repositories | Repository implementations |
| presentation/bloc | State management (BLoC/Cubit) |
| presentation/pages | UI screens |

## Screens

| # | Screen | Route |
|---|--------|-------|
| 1 | Welcome | /welcome |
| 2 | Sign In | /sign-in |
| 3 | Goal Selection | /onboarding/goals |
| 4 | Personal Metrics | /onboarding/metrics |
| 5 | Health Limits | /onboarding/health |
| 6 | Home Dashboard | /home |
| 7 | Workout Plan | /home/plan |
| 8 | Workout Details | /home/plan/:id |
| 9 | Active Workout | /workout/active |
| 10 | Post-Workout Summary | /workout/summary |
| 11 | Progress | /home/progress |
| 12 | Profile | /home/profile |
| 13 | Exercise Library | /home/workouts |
| 14 | Add Exercise | /home/workouts/add |

## Environment Variables

Copy `.env.example` to `.env` and fill in values:

```
API_BASE_URL=https://api.fitness-app.example.com
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

## Notes

- Google Sign-In is currently simulated (demo mode). For production, configure a real Google OAuth client ID.
- All data is stored locally using SharedPreferences.
- The app is ready for backend API integration via the Dio network layer.
