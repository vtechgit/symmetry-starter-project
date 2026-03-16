# Dependency Update Guide

## Context

This project uses Flutter with a set of dependencies originally written for older Flutter/Dart versions. When upgrading Flutter or running the project on a new machine with a recent Flutter install, you may encounter build failures caused by outdated packages.

## Known Breaking Changes in Flutter

### v1 Android Embedding Removal (Flutter 3.19+)

Flutter 3.19 (February 2024) removed support for the v1 Android plugin embedding API. Plugins compiled against it fail with:

```
error: cannot find symbol
  PluginRegistry.Registrar
```

Affected packages in this project: `file_picker 6.x`, `path_provider_android 2.2.2`.

### `UnmodifiableUint8ListView` Removal (Dart 3.8+)

Dart 3.8 removed `UnmodifiableUint8ListView` from `dart:typed_data`. The `win32` package below version `5.5.0` uses it, causing:

```
Error: Type 'UnmodifiableUint8ListView' not found.
```

`win32` is a transitive dependency of `file_picker`. A `dependency_overrides` entry in `pubspec.yaml` forces a compatible version:

```yaml
dependency_overrides:
  win32: ^5.5.0
```

## How to Fix Build Failures After a Flutter Upgrade

If the app fails to build after updating Flutter, run:

```bash
cd frontend
flutter pub upgrade
flutter pub get
```

This upgrades all dependencies (direct and transitive) to their latest versions compatible with the current Dart/Flutter SDK.

If individual packages still fail, check:

```bash
flutter pub outdated
```

And update the specific constraint in `pubspec.yaml`.

## Android Build Configuration Requirements

The following minimum versions are required for Flutter 3.19+ / Dart 3.8+:

| Tool | Minimum Version | File |
|------|----------------|------|
| Gradle | 8.7 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin (AGP) | 8.6.0 | `android/settings.gradle` |
| Kotlin | 2.1.0 | `android/settings.gradle`, `android/app/build.gradle` |

These were updated in the `fix/android-build-versions` branch to resolve the initial build failure.

## Security Advisories

`dio 4.0.6` (the HTTP client used for NewsAPI) has known security advisories. Upgrading to `dio ^5.0.0` requires API changes in the data layer (request options, response handling). This has not been done yet to avoid breaking changes.

To check current advisory status:

```bash
flutter pub outdated
```
