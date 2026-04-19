import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

enum LocationPermissionStatus { granted, denied, deniedForever, serviceOff }

class LocationService {
  StreamSubscription<Position>? _sub;

  /// Google Maps API key (same one used in AndroidManifest.xml).
  static const _googleApiKey = 'AIzaSyD4gQlVQKoVsbDJGuYJ7GVtLQYw9N9WWW8';

  Future<LocationPermissionStatus> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationPermissionStatus.serviceOff;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (!kIsWeb && Platform.isIOS && p == LocationPermission.whileInUse) {
      try {
        p = await Geolocator.requestPermission();
      } catch (_) {}
    }
    if (p == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (p == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }
    return LocationPermissionStatus.granted;
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
    String address = '${p.latitude.toStringAsFixed(4)}, '
        '${p.longitude.toStringAsFixed(4)}';
    try {
      final isAndroid = !kIsWeb && Platform.isAndroid;
      if (isAndroid) {
        address = await _reverseGeocodeGoogle(p.latitude, p.longitude) ??
            address;
      } else {
        address = await _reverseGeocodeNative(p.latitude, p.longitude) ??
            address;
      }
    } catch (_) {}
    return LocationFix(lat: p.latitude, lng: p.longitude, address: address);
  }

  /// Uses the native Geocoder (reliable on iOS).
  Future<String?> _reverseGeocodeNative(double lat, double lng) async {
    final places = await placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return null;
    final pl = places.first;
    final parts = [
      if ((pl.street ?? '').isNotEmpty) pl.street,
      if ((pl.locality ?? '').isNotEmpty) pl.locality,
      if ((pl.administrativeArea ?? '').isNotEmpty) pl.administrativeArea,
    ].whereType<String>().toList();
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// Uses the Google Maps Geocoding HTTP API (reliable on Android).
  Future<String?> _reverseGeocodeGoogle(double lat, double lng) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&key=$_googleApiKey'
      '&result_type=street_address|route|locality'
      '&language=ru',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;
    final formatted = results.first['formatted_address'] as String?;
    return (formatted != null && formatted.isNotEmpty) ? formatted : null;
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
