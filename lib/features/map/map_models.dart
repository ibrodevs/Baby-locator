import 'package:flutter/material.dart';

class ParentMapLocation {
  const ParentMapLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;
}

class MapLatLng {
  const MapLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class MapCircle {
  const MapCircle({
    required this.id,
    required this.center,
    required this.radiusMeters,
    required this.strokeColor,
    required this.fillColor,
    this.strokeWidth = 2,
  });

  final String id;
  final MapLatLng center;
  final double radiusMeters;
  final int strokeWidth;
  final Color strokeColor;
  final Color fillColor;
}
