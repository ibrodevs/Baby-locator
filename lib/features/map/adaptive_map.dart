import 'dart:io' show Platform;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Real Apple Map on iOS, painted fallback elsewhere.
/// Rebuilds camera when [latitude]/[longitude] change.
class AdaptiveMap extends StatefulWidget {
  const AdaptiveMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label = 'Child',
  });

  final double latitude;
  final double longitude;
  final String label;

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  am.AppleMapController? _ctrl;

  @override
  void didUpdateWidget(covariant AdaptiveMap old) {
    super.didUpdateWidget(old);
    if (_ctrl != null &&
        (old.latitude != widget.latitude ||
            old.longitude != widget.longitude)) {
      _ctrl!.animateCamera(
        am.CameraUpdate.newLatLng(
            am.LatLng(widget.latitude, widget.longitude)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApple = !kIsWeb && Platform.isIOS;
    if (isApple) {
      final pos = am.LatLng(widget.latitude, widget.longitude);
      return am.AppleMap(
        initialCameraPosition: am.CameraPosition(target: pos, zoom: 16),
        myLocationEnabled: true,
        compassEnabled: false,
        onMapCreated: (c) => _ctrl = c,
        annotations: {
          am.Annotation(
            annotationId: am.AnnotationId('child'),
            position: pos,
            infoWindow: am.InfoWindow(title: widget.label),
          ),
        },
      );
    }
    return _PaintedMap(label: widget.label);
  }
}

class _PaintedMap extends StatelessWidget {
  const _PaintedMap({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFE7DC),
      child: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  label.isEmpty ? '?' : label[0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 4;
    for (double y = 30; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 8), thin);
    }
    for (double x = 30; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x - 8, size.height), thin);
    }
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.5), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
