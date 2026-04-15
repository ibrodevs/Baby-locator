# Kid Security

Parental GPS tracking app built with Flutter. Uses **Apple Maps on iOS** and
**Google Maps on Android** automatically via a platform-adaptive map layer.

## Features

- Live map with child marker, parent marker, and movement polyline
- Simulated real-time tracking (marker moves every 3 seconds)
- Modern iOS-inspired UI: blur/glass effects, rounded cards, floating bottom nav
- Light and dark theme support
- Clean architecture: `presentation` / `domain` / `data` layering via
  `features/`, `models/`, `services/`
- State management with **Riverpod**
- Bottom sheet with child card + quick actions (Call, Message, Safe Zone, History)
- Multi-child switcher in the top bar
- Profile and Settings screens

## Project structure

```
lib/
├── main.dart                # entry point
├── app.dart                 # MaterialApp + theming
├── core/
│   ├── theme/               # colors, text styles, ThemeData
│   └── constants/
├── models/                  # Child, GeoLocation
├── services/                # LocationService (abstract) + mock impl, MapService
└── features/
    ├── root/                # bottom-nav scaffold
    ├── map/
    │   ├── providers/
    │   ├── widgets/         # AdaptiveMap, controls, bottom sheet, top bar
    │   └── map_screen.dart
    ├── child/providers/
    ├── profile/
    └── settings/
```

The **presentation layer** is everything under `features/*/*_screen.dart`
and `features/*/widgets/`. The **domain layer** is `models/` plus the abstract
`LocationService` interface. The **data layer** is `services/mock_location_service.dart`
(swap for a real implementation without touching UI).

## Getting started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. iOS setup (Apple Maps)

Apple Maps is included automatically via MapKit — no API key required.
You only need to add location-usage strings to `ios/Runner/Info.plist`.

Copy the keys from `ios/Runner/Info.plist.snippet.xml` into the `<dict>`
block of your `Info.plist`. Minimum iOS version: **12.0** (set in
`ios/Podfile`: `platform :ios, '12.0'`).

Then:

```bash
cd ios && pod install && cd ..
flutter run -d <ios simulator or device>
```

### 3. Android setup (Google Maps)

1. Get a Google Maps API key from the
   [Google Cloud Console](https://console.cloud.google.com/). Enable **Maps SDK for Android**.
2. Paste the permissions + `<meta-data>` block from
   `android/app/src/main/AndroidManifest.snippet.xml` into your
   `AndroidManifest.xml` (replace `YOUR_GOOGLE_MAPS_API_KEY`).
3. Ensure `minSdkVersion 21` in `android/app/build.gradle`.

Then:

```bash
flutter run -d <android emulator or device>
```

### 4. Platform auto-detection

No special work needed in app code — `MapService.isApple` picks the right
renderer. You can force a specific platform during development by editing
`lib/services/map_service.dart`.

## How it works

### Mock real-time movement

`MockLocationService` holds an in-memory list of children and starts a
`Timer.periodic` (every 3 s) that nudges each child's coordinates by a
small random delta, appends the point to their history (capped at 60
points), and emits the new state through a broadcast `StreamController`.

The UI subscribes via `childStreamProvider.family(id)`. When the selected
child moves and *follow mode* is on, `MapScreen` listens to the provider
and calls `AdaptiveMapController.animateTo()` to recenter the camera.

### Adaptive map

`AdaptiveMap` (in `features/map/widgets/adaptive_map.dart`) renders either
`GoogleMap` or `AppleMap` depending on `MapService.isApple`. It exposes a
single `AdaptiveMapController` with `animateTo`, `zoomIn`, `zoomOut` so
callers never touch platform types.

## Plugging in a real backend

The UI and providers depend only on the abstract `LocationService`
interface in `lib/services/mock_location_service.dart`. To switch to a
real backend:

1. Create `lib/services/api_location_service.dart` implementing
   `LocationService` — use `package:dio` / `http` for REST, or
   `cloud_firestore` / `socket_io_client` for live updates.
2. Override the provider in `main.dart`:

   ```dart
   runApp(ProviderScope(
     overrides: [
       locationServiceProvider.overrideWithValue(ApiLocationService(...)),
     ],
     child: const KidSecurityApp(),
   ));
   ```

3. Map your backend payloads to `Child` / `GeoLocation` inside the new
   service — no UI code needs to change.

### Replace mock data with a live API

- `fetchChildren()` → `GET /children`
- `fetchParentLocation()` → device GPS via `package:geolocator`
- `watchChild(id)` → WebSocket / SSE / Firestore snapshots yielding
  `Child` updates

### Performance tips

- Cap polyline length (already done — 60 points). For long histories,
  render a simplified path (Douglas–Peucker) and keep the full series
  for analytics.
- Debounce camera animations so rapid ticks don't fight the user's
  gesture input.
- Use `const` constructors aggressively (the codebase already does).
- Marker icons: swap `defaultMarkerWithHue` for a custom bitmap cached
  once at startup; don't rebuild it per frame.
- For >10 children, migrate `childStreamProvider.family` to a single
  stream that emits a `Map<String, Child>` keyed snapshot.

## Running tests

```bash
flutter test
```

(No tests are shipped yet — add them under `test/` mirroring `lib/`.)

## Notes on design fidelity

The UI is built against the design brief (iOS-inspired glassy nav,
lavender primary `#6C5CE7`, rounded 20–28 px corners, 3-size snap
bottom sheet). If you need exact pixel-perfect values from the Figma
file, export the tokens and update `lib/core/theme/app_colors.dart` +
`app_text_styles.dart` — all styling goes through those two files.
