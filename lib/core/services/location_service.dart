import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

  Future<LocationPermissionStatus> ensurePermission() async {
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
      final places = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (places.isNotEmpty) {
        final pl = places.first;
        final parts = [
          if ((pl.street ?? '').isNotEmpty) pl.street,
          if ((pl.locality ?? '').isNotEmpty) pl.locality,
          if ((pl.administrativeArea ?? '').isNotEmpty) pl.administrativeArea,
        ].whereType<String>().toList();
        if (parts.isNotEmpty) address = parts.join(', ');
      }
    } catch (_) {}
    return LocationFix(lat: p.latitude, lng: p.longitude, address: address);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
