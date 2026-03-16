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

## Firebase SDK v2 → v3 Migration (March 2026)

### Problem

Compiling for web with Flutter 3.41+ failed with errors like:

```
Error: Type 'PromiseJsImpl' not found.
Error: Method not found: 'handleThenable'.
Error: Method not found: 'dartify'.
```

These came from `firebase_auth_web 5.8.13` and `firebase_storage_web 3.6.22`, which still used old JS interop utilities (`PromiseJsImpl`, `handleThenable`, `dartify`, `jsify`) that were removed from `firebase_core_web 2.17+`.

### Fix

Upgraded all Firebase packages from the v2 series to v3:

| Package | Before | After |
|---------|--------|-------|
| `firebase_core` | `^2.24.0` | `^3.0.0` |
| `firebase_auth` | `^4.16.0` | `^5.0.0` |
| `cloud_firestore` | `^4.13.3` | `^5.0.0` |
| `firebase_storage` | `^11.5.5` | `^12.0.0` |

The v3 series rewrote the web interop layer using `dart:js_interop`, eliminating the dependency on the removed utilities. No application code changes were required.

Resolved transitive versions: `firebase_auth_web 5.15.3`, `firebase_storage_web 3.10.17`, `firebase_core_web 2.24.1`, `cloud_firestore_web 4.4.12`.

---

## Security Advisories

`dio 4.0.6` (the HTTP client used for NewsAPI) has known security advisories. Upgrading to `dio ^5.0.0` requires API changes in the data layer (request options, response handling). This has not been done yet to avoid breaking changes.

To check current advisory status:

```bash
flutter pub outdated
```
