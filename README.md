<div align="center">

# Family Security

### Cross-platform parental safety and family location application

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
![Status](https://img.shields.io/badge/status-active_development-22C55E?style=flat-square)
![Platforms](https://img.shields.io/badge/platforms-iOS_%7C_Android-6366F1?style=flat-square)

[Backend API](https://github.com/ibrodevs/Baby-locator-backend) · [Web experience](https://github.com/ibrodevs/Baby-locator-web)

</div>

## Overview

Family Security is a cross-platform mobile product designed to help parents stay connected with their children and respond quickly when something needs attention. The application combines location, device-level safety tools, notifications, and premium family features in one clear interface.

The project demonstrates product design, Flutter architecture, native Android integration, real-time communication, background execution, and API-driven mobile development.

## Product capabilities

- Live family map with child and parent locations
- Apple Maps on iOS and Google Maps on Android through one adaptive map layer
- Multi-child profiles, movement history, and quick family actions
- Background location and device-state services
- Firebase Cloud Messaging and local notifications
- WebRTC-based audio monitoring flows
- SOS, loud-signal, and safety alert experiences
- Android application blocking through an Accessibility Service bridge
- App-usage and screen-time related controls
- RevenueCat subscriptions and premium entitlement handling
- Light and dark themes with localized interface support

## Architecture

The application is organized by feature and responsibility:

- **Presentation:** screens, reusable widgets, and interaction states
- **State:** Riverpod providers and reactive feature state
- **Domain:** family, child, location, and safety models
- **Data:** REST services, local storage, Firebase, and platform services
- **Native bridge:** Android-specific capabilities isolated in a local Flutter package

~~~text
lib/
├── core/          # theme, shared services, constants
├── features/      # map, child, profile, settings, safety flows
├── models/        # domain models
└── services/      # API, location, notifications, device services

packages/
└── kid_security_android_bridge/
~~~

## Technology

| Area | Technology |
|---|---|
| Mobile | Flutter, Dart |
| State management | Riverpod |
| Maps & location | Google Maps, Apple Maps, Geolocator |
| Communication | Firebase Messaging, WebRTC |
| Device integration | Background services, permissions, native Android bridge |
| Monetization | RevenueCat |
| API | REST integration with Django REST backend |

## Getting started

### Requirements

- Flutter 3.19 or newer
- Dart 3.3 or newer
- Xcode for iOS development
- Android Studio and Android SDK for Android development
- Firebase and map credentials for the target environments

### Install and run

~~~bash
flutter pub get
flutter run
~~~

### Platform configuration

- Add the required location permission descriptions to the iOS Info.plist.
- Configure the Google Maps key and background permissions on Android.
- Add the appropriate Firebase configuration files for each platform.
- Enable required device permissions when testing background and safety features.

## Quality checks

~~~bash
flutter analyze
flutter test
~~~

Some device-level features must be tested on physical devices because simulators do not fully reproduce background execution, permissions, audio, or Accessibility Service behavior.

## Related repositories

- [Family Security backend](https://github.com/ibrodevs/Baby-locator-backend) — Django REST API and server-side product logic
- [Family Security web](https://github.com/ibrodevs/Baby-locator-web) — supporting web experience

## Project note

This repository is an active product codebase. Platform credentials, production secrets, and environment-specific signing configuration are intentionally not documented in the repository.

