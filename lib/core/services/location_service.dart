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

  Future<LocationPermissionStatus> ensurePermission({
    bool requireBackground = false,
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationPermissionStatus.serviceOff;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }

    if (p == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (p == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }

    // Background upgrade. Geolocator on Android stops at whileInUse; we need
    // the ACCESS_BACKGROUND_LOCATION runtime grant so the foreground service
    // keeps receiving updates once the screen is off.
    if (requireBackground && !kIsWeb) {
      if (Platform.isAndroid && p == LocationPermission.whileInUse) {
        final always = await ph.Permission.locationAlways.request();
        if (!always.isGranted) {
          return LocationPermissionStatus.backgroundDenied;
        }
        p = await Geolocator.checkPermission();
      } else if (Platform.isIOS && p == LocationPermission.whileInUse) {
        try {
          p = await Geolocator.requestPermission();
        } catch (_) {}
        if (p == LocationPermission.whileInUse) {
          return LocationPermissionStatus.backgroundDenied;
        }
      }
    }

    return LocationPermissionStatus.granted;
  }

  /// Best-effort request for Android's ACCESS_BACKGROUND_LOCATION.
  /// Must be called AFTER whileInUse has been granted — Android will silently
  /// deny otherwise.
  Future<bool> requestBackgroundPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final fg = await Geolocator.checkPermission();
    if (fg == LocationPermission.denied || fg == LocationPermission.deniedForever) {
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

  Future<LocationFix?> currentOnce() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return _toFix(pos);
  }

  Stream<LocationFix> watch() {
    _sub?.cancel();
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    );
    return stream.asyncMap(_toFix);
  }

  Future<LocationFix> _toFix(Position p) async {
    String address = '';
    try {
      final isAndroid = !kIsWeb && Platform.isAndroid;
      if (isAndroid) {
        address =
            await _reverseGeocodeGoogle(p.latitude, p.longitude) ?? address;
      } else {
        address =
            await _reverseGeocodeNative(p.latitude, p.longitude) ?? address;
      }
    } catch (_) {}
    return LocationFix(lat: p.latitude, lng: p.longitude, address: address);
  }

  /// Uses the native Geocoder (reliable on iOS).
  Future<String?> _reverseGeocodeNative(double lat, double lng) async {
    await setLocaleIdentifier(await _preferredLocaleTag());
    final places = await placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return null;
    final pl = places.first;

    // Build a precise address: street + house number, district, city.
    final thoroughfare = (pl.thoroughfare ?? '').trim();
    final subThoroughfare = (pl.subThoroughfare ?? '').trim();
    final subLocality = (pl.subLocality ?? '').trim();
    final locality = (pl.locality ?? '').trim();

    // Combine street name and house number.
    String streetPart = '';
    if (thoroughfare.isNotEmpty && subThoroughfare.isNotEmpty) {
      streetPart = '$thoroughfare $subThoroughfare';
    } else if (thoroughfare.isNotEmpty) {
      streetPart = thoroughfare;
    } else if ((pl.street ?? '').trim().isNotEmpty) {
      // Fallback: some platforms put the full address in `street`.
      streetPart = pl.street!.trim();
    }

    final parts = [
      if (streetPart.isNotEmpty) streetPart,
      if (subLocality.isNotEmpty && subLocality != streetPart) subLocality,
      if (locality.isNotEmpty) locality,
    ];
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// Uses the Google Maps Geocoding HTTP API (reliable on Android).
  Future<String?> _reverseGeocodeGoogle(double lat, double lng) async {
    final languageCode = await _preferredLanguageCode();
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&key=$_googleApiKey'
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
