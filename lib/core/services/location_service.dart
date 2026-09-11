import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

const _preferredLocaleKey = 'preferred_locale';

class LocationFix {
  LocationFix({
    required this.lat,
    required this.lng,
    required this.address,
  });
  final double lat;
  final double lng;
  final String address;
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceOff,
  backgroundDenied,
}

class LocationService {
  StreamSubscription<Position>? _sub;

  /// Google Maps API key (same one used in AndroidManifest.xml).
  static const _googleApiKey = 'AIzaSyD4gQlVQKoVsbDJGuYJ7GVtLQYw9N9WWW8';

  /// Checks the current location permission WITHOUT ever triggering a system
  /// permission dialog. A request must only ever happen through
  /// [requestForegroundPermission] / [requestBackgroundPermission], both of
  /// which are called from UI that shows the prominent disclosure first. This
  /// guarantees no screen can surface the Android location prompt before the
  /// user has seen the disclosure (Google Play prominent-disclosure policy).
  Future<LocationPermissionStatus> ensurePermission({
    bool requireBackground = false,
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationPermissionStatus.serviceOff;
    final p = await Geolocator.checkPermission();

    if (p == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (p == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }

    if (requireBackground && !kIsWeb) {
      if (Platform.isAndroid && p == LocationPermission.whileInUse) {
        final status = await ph.Permission.locationAlways.status;
        if (!status.isGranted) {
          return LocationPermissionStatus.backgroundDenied;
        }
      } else if (Platform.isIOS && p == LocationPermission.whileInUse) {
        return LocationPermissionStatus.backgroundDenied;
      }
    }

    return LocationPermissionStatus.granted;
  }

  /// Requests the foreground (while-in-use) location permission.
  ///
  /// MUST only be called AFTER the prominent disclosure has been shown and
  /// accepted by the user. This is the single entry point that surfaces the
  /// Android foreground-location prompt — [ensurePermission] never does.
  Future<bool> requestForegroundPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final result = await Geolocator.requestPermission();
    return result == LocationPermission.always ||
        result == LocationPermission.whileInUse;
  }

  /// Request Android's ACCESS_BACKGROUND_LOCATION directly only after disclosure has been accepted.
  Future<bool> requestBackgroundPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final fg = await Geolocator.checkPermission();
    if (fg == LocationPermission.denied ||
        fg == LocationPermission.deniedForever) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return false;
      }
    }

    if (Platform.isAndroid) {
      final status = await ph.Permission.locationAlways.status;
      if (status.isGranted) return true;
      final result = await ph.Permission.locationAlways.request();
      return result.isGranted;
    }

    // iOS: Geolocator will promote to always on the second call.
    final p = await Geolocator.requestPermission();
    return p == LocationPermission.always;
  }

  Future<bool> hasBackgroundPermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      return (await ph.Permission.locationAlways.status).isGranted;
    }
    if (Platform.isIOS) {
      return (await Geolocator.checkPermission()) == LocationPermission.always;
    }
    return true;
  }

  /// Returns the last known position instantly (no GPS wait).
  /// Returns null if the platform has no cached fix at all.
  Future<LocationFix?> getLastKnown() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) return await _toFix(pos);
    } catch (_) {}
    return null;
  }

  /// Gets the current position. First tries to return quickly with high
  /// accuracy; if that takes too long falls back to low accuracy.
  Future<LocationFix?> currentOnce() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      return await _toFix(pos);
    } catch (_) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 7),
        );
        return await _toFix(pos);
      } catch (_) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) return await _toFix(lastKnown);
        } catch (_) {}
      }
    }
    return null;
  }

  Stream<LocationFix> watch() {
    _sub?.cancel();
    LocationSettings settings;
    if (!kIsWeb && Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 10),
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }
    final stream = Geolocator.getPositionStream(locationSettings: settings);
    return stream.asyncMap(_toFix);
  }

  Future<LocationFix> _toFix(Position p) async {
    String address = '';
    // 1. Try device OS native geocoder (offline/direct on Android and iOS).
    try {
      address = await _reverseGeocodeNative(p.latitude, p.longitude) ?? '';
    } catch (_) {}

    // 2. Fallback to OpenStreetMap Nominatim if native produced no address or only street without house number.
    if (address.trim().isEmpty || !_hasHouseNumber(address)) {
      try {
        final osmAddress = await _reverseGeocodeNominatim(p.latitude, p.longitude);
        if (osmAddress != null && osmAddress.trim().isNotEmpty) {
          address = osmAddress.trim();
        }
      } catch (_) {}
    }

    // 3. Fallback to Google HTTP geocoder if still empty.
    if (address.trim().isEmpty) {
      try {
        address = await _reverseGeocodeGoogle(p.latitude, p.longitude) ?? '';
      } catch (_) {}
    }

    // 4. Guarantee that address is NEVER empty string, preventing UI from hanging on "Resolving address...".
    if (address.trim().isEmpty) {
      address = '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
    }

    return LocationFix(lat: p.latitude, lng: p.longitude, address: address);
  }

  static bool _hasHouseNumber(String address) {
    return RegExp(r'\d').hasMatch(address);
  }

  /// Uses the native Geocoder (reliable on iOS and Android).
  Future<String?> _reverseGeocodeNative(double lat, double lng) async {
    await setLocaleIdentifier(await _preferredLocaleTag());
    final places = await placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return null;
    return _formatPlacemark(places.first);
  }

  /// Formats a Placemark prioritizing exact house number and street name.
  static String? _formatPlacemark(Placemark pl) {
    final thoroughfare = (pl.thoroughfare ?? '').trim();
    final subThoroughfare = (pl.subThoroughfare ?? '').trim();
    final street = (pl.street ?? '').trim();
    final name = (pl.name ?? '').trim();
    final subLocality = (pl.subLocality ?? '').trim();
    final locality = (pl.locality ?? '').trim();

    String streetPart = '';

    // 1. If both thoroughfare (street) and subThoroughfare (house number) exist:
    if (thoroughfare.isNotEmpty && subThoroughfare.isNotEmpty) {
      streetPart = '$thoroughfare, $subThoroughfare';
    }
    // 2. If street already contains digits (house number included):
    else if (street.isNotEmpty && RegExp(r'\d').hasMatch(street)) {
      streetPart = street;
    }
    // 3. If name contains digits and differs from thoroughfare (e.g. name="158", thoroughfare="ул. Киевская"):
    else if (thoroughfare.isNotEmpty &&
        name.isNotEmpty &&
        name != thoroughfare &&
        RegExp(r'\d').hasMatch(name)) {
      streetPart = '$thoroughfare, $name';
    }
    // 4. If street is provided and non-empty:
    else if (street.isNotEmpty) {
      if (name.isNotEmpty && name != street && RegExp(r'\d').hasMatch(name)) {
        streetPart = '$street, $name';
      } else {
        streetPart = street;
      }
    }
    // 5. Fall back to thoroughfare with name:
    else if (thoroughfare.isNotEmpty) {
      if (name.isNotEmpty && name != thoroughfare) {
        streetPart = '$thoroughfare, $name';
      } else {
        streetPart = thoroughfare;
      }
    } else if (name.isNotEmpty) {
      streetPart = name;
    }

    final parts = [
      if (streetPart.isNotEmpty) streetPart,
      if (subLocality.isNotEmpty && subLocality != streetPart && subLocality != locality) subLocality,
      if (locality.isNotEmpty) locality,
    ];
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// OpenStreetMap Nominatim reverse geocoding fallback for exact street and house number.
  Future<String?> _reverseGeocodeNominatim(double lat, double lng) async {
    final languageCode = await _preferredLanguageCode();
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lng'
      '&format=json'
      '&accept-language=$languageCode',
    );
    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'BabyLocatorApp/1.0 (support@baby-locator.online)',
      },
    ).timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final address = json['address'] as Map<String, dynamic>?;
    if (address == null) {
      final displayName = json['display_name'] as String?;
      return (displayName != null && displayName.isNotEmpty) ? displayName : null;
    }

    final road = (address['road'] ?? address['pedestrian'] ?? address['street'] ?? '').toString().trim();
    final houseNumber = (address['house_number'] ?? '').toString().trim();
    final district = (address['city_district'] ?? address['suburb'] ?? address['neighbourhood'] ?? '').toString().trim();
    final city = (address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? '').toString().trim();

    String streetPart = '';
    if (road.isNotEmpty && houseNumber.isNotEmpty) {
      streetPart = '$road, $houseNumber';
    } else if (road.isNotEmpty) {
      streetPart = road;
    } else if (houseNumber.isNotEmpty) {
      streetPart = houseNumber;
    }

    final parts = [
      if (streetPart.isNotEmpty) streetPart,
      if (district.isNotEmpty && district != streetPart && district != city) district,
      if (city.isNotEmpty) city,
    ];

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    final displayName = json['display_name'] as String?;
    return (displayName != null && displayName.isNotEmpty) ? displayName : null;
  }

  /// Uses the Google Maps Geocoding HTTP API (reliable on Android).
  Future<String?> _reverseGeocodeGoogle(double lat, double lng) async {
    final languageCode = await _preferredLanguageCode();
    final dynamicKey = await ApiClient.instance.getGoogleMapsApiKey();
    final key = (dynamicKey != null && dynamicKey.isNotEmpty) ? dynamicKey : _googleApiKey;
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&key=$key'
      '&language=$languageCode',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    // Pick the most precise result: prefer street_address, then route,
    // then the first available result.
    Map<String, dynamic>? best;
    for (final result in results) {
      final r = result as Map<String, dynamic>;
      final types = (r['types'] as List<dynamic>?)?.cast<String>() ?? [];
      if (types.contains('street_address')) {
        best = r;
        break;
      }
      if (best == null && types.contains('route')) {
        best = r;
      }
    }
    best ??= results.first as Map<String, dynamic>;

    final formatted = best['formatted_address'] as String?;
    return (formatted != null && formatted.isNotEmpty) ? formatted : null;
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<String> _preferredLocaleTag() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTag = prefs.getString(_preferredLocaleKey);
    final fallbackTag = ui.PlatformDispatcher.instance.locale.toLanguageTag();
    final normalized = (storedTag?.trim().isNotEmpty ?? false)
        ? storedTag!.replaceAll('_', '-')
        : fallbackTag.replaceAll('_', '-');
    return normalized.isEmpty ? 'en' : normalized;
  }

  Future<String> _preferredLanguageCode() async {
    final tag = await _preferredLocaleTag();
    final languageCode = tag.split('-').first.toLowerCase();
    return languageCode.isEmpty ? 'en' : languageCode;
  }
}
