# Masaj Feedback App

Flutter Android app for collecting user feedback with optional image attachments.

## Configuration

Pass Supabase credentials at run/build time:

```powershell
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

## Validate

```powershell
flutter pub get
flutter analyze
flutter test
```

## Build APK

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

The release APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```
