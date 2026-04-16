import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:http/http.dart' as http;

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import 'apple_map_web_stub.dart'
    if (dart.library.js_interop) 'apple_map_web.dart';

/// Real Apple Map on iOS/Web, Google Map on Android, painted fallback elsewhere.
/// Shows all children as markers on the map.
class AdaptiveMap extends StatefulWidget {
  const AdaptiveMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.children = const [],
    this.selectedIndex,
    this.onChildTapped,
    this.onCameraMove,
  });

  final double latitude;
  final double longitude;
  final List<ChildLocation> children;
  final int? selectedIndex;
  final ValueChanged<int>? onChildTapped;
  final Function(double lat, double lng)? onCameraMove;

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  am.AppleMapController? _appleCtrl;
  gm.GoogleMapController? _googleCtrl;
  final Map<int, gm.BitmapDescriptor> _googleMarkers = {};
  final Map<int, am.BitmapDescriptor> _appleMarkers = {};
  final Map<String, ui.Image> _avatarCache = {};

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    if (widget.children.isEmpty) return;

    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      final key = child.childId ?? i;
      final bytes = await _generateMarkerBytes(child);
      if (!mounted) return;

      setState(() {
        _googleMarkers[key] = gm.BitmapDescriptor.fromBytes(bytes);
        _appleMarkers[key] = am.BitmapDescriptor.fromBytes(bytes);
      });
    }
  }

  Future<ui.Image?> _loadNetworkImage(String url) async {
    if (_avatarCache.containsKey(url)) return _avatarCache[url];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      _avatarCache[url] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _generateMarkerBytes(ChildLocation child) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double size = 120.0;
    const double radius = size / 2;
    const double borderWidth = 5.0;
    const double labelHeight = 24.0;
    const double totalHeight = size + labelHeight + 16; // marker + label + pin

    // Try to load avatar image
    ui.Image? avatarImage;
    if (child.avatarUrl != null && child.avatarUrl!.isNotEmpty) {
      avatarImage = await _loadNetworkImage(child.avatarUrl!);
    }

    // White border circle
    final borderPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(radius, radius + 2), radius, shadowPaint);

    // White border again on top of shadow
    canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);

    if (avatarImage != null) {
      // Clip to circle and draw avatar
      canvas.save();
      final clipPath = Path()
        ..addOval(Rect.fromCircle(
            center: const Offset(radius, radius),
            radius: radius - borderWidth));
      canvas.clipPath(clipPath);

      final srcRect = Rect.fromLTWH(0, 0, avatarImage.width.toDouble(),
          avatarImage.height.toDouble());
      final dstRect = Rect.fromCircle(
          center: const Offset(radius, radius),
          radius: radius - borderWidth);
      canvas.drawImageRect(avatarImage, srcRect, dstRect, Paint());
      canvas.restore();
    } else {
      // Draw colored circle with initials
      final bgPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(
          const Offset(radius, radius), radius - borderWidth, bgPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
            radius - textPainter.width / 2, radius - textPainter.height / 2),
      );
    }

    // Draw name label below
    final namePainter = TextPainter(
      text: TextSpan(
        text: child.name.length > 8
            ? child.name.substring(0, 8).toUpperCase()
            : child.name.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          background: Paint()
            ..color = AppColors.primary.withOpacity(0.85)
            ..style = PaintingStyle.fill,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();

    // Label background
    final labelY = size + 4;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(radius, labelY + labelHeight / 2),
        width: namePainter.width + 16,
        height: labelHeight,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
        labelRect, Paint()..color = AppColors.primary.withOpacity(0.85));
    namePainter.paint(
      canvas,
      Offset(radius - namePainter.width / 2, labelY + 4),
    );

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(size.toInt(), totalHeight.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  @override
  void didUpdateWidget(covariant AdaptiveMap old) {
    super.didUpdateWidget(old);
    if (old.children.length != widget.children.length) {
      _loadCustomMarkers();
    }
    if (old.latitude != widget.latitude || old.longitude != widget.longitude) {
      _appleCtrl?.animateCamera(
        am.CameraUpdate.newLatLng(am.LatLng(widget.latitude, widget.longitude)),
      );
      _googleCtrl?.animateCamera(
        gm.CameraUpdate.newLatLng(gm.LatLng(widget.latitude, widget.longitude)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // На iOS (не web) используем Apple Maps
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildAppleMap();
    }

    // В Web используем Apple MapKit JS
    if (kIsWeb) {
      return AppleMapWeb(
        latitude: widget.latitude,
        longitude: widget.longitude,
        children: widget.children,
        onChildTapped: widget.onChildTapped,
      );
    }

    // На Android используем Google Maps
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildGoogleMap();
    }

    // Fallback на рисованную карту для остальных платформ (macOS, Windows, etc.)
    return _PaintedMap(
      children: widget.children,
      selectedIndex: widget.selectedIndex,
      onChildTapped: widget.onChildTapped,
    );
  }

  Widget _buildAppleMap() {
    final pos = am.LatLng(widget.latitude, widget.longitude);
    final annotations = <am.Annotation>{};
    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      final key = c.childId ?? i;
      annotations.add(am.Annotation(
        annotationId: am.AnnotationId('child_$key'),
        position: am.LatLng(c.lat, c.lng),
        icon: _appleMarkers[key] ?? am.BitmapDescriptor.defaultAnnotation,
        infoWindow: am.InfoWindow(
          title: c.name,
          snippet: '${c.battery}% battery',
        ),
        onTap: () => widget.onChildTapped?.call(i),
      ));
    }
    return am.AppleMap(
      initialCameraPosition: am.CameraPosition(target: pos, zoom: 14),
      compassEnabled: false,
      onMapCreated: (c) => _appleCtrl = c,
      onCameraMove: widget.onCameraMove != null
          ? (pos) =>
              widget.onCameraMove!(pos.target.latitude, pos.target.longitude)
          : null,
      annotations: annotations,
    );
  }

  Widget _buildGoogleMap() {
    final pos = gm.LatLng(widget.latitude, widget.longitude);
    final markers = <gm.Marker>{};
    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      final key = c.childId ?? i;
      markers.add(gm.Marker(
        markerId: gm.MarkerId('child_$key'),
        position: gm.LatLng(c.lat, c.lng),
        icon: _googleMarkers[key] ?? gm.BitmapDescriptor.defaultMarker,
        infoWindow: gm.InfoWindow(
          title: c.name,
          snippet: '${c.battery}% battery',
        ),
        onTap: () => widget.onChildTapped?.call(i),
      ));
    }
    return gm.GoogleMap(
      initialCameraPosition: gm.CameraPosition(target: pos, zoom: 14),
      onMapCreated: (c) => _googleCtrl = c,
      onCameraMove: widget.onCameraMove != null
          ? (pos) =>
              widget.onCameraMove!(pos.target.latitude, pos.target.longitude)
          : null,
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

class _PaintedMap extends StatelessWidget {
  const _PaintedMap({
    required this.children,
    this.selectedIndex,
    this.onChildTapped,
  });
  final List<ChildLocation> children;
  final int? selectedIndex;
  final ValueChanged<int>? onChildTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFE7DC),
      child: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          if (children.isEmpty)
            Center(
              child: _ChildMarker(
                label: '?',
                name: '',
                isSelected: false,
                onTap: null,
              ),
            )
          else
            ..._positionedMarkers(context),
        ],
      ),
    );
  }

  List<Widget> _positionedMarkers(BuildContext context) {
    if (children.isEmpty) return [];

    double minLat = children.first.lat, maxLat = children.first.lat;
    double minLng = children.first.lng, maxLng = children.first.lng;
    for (final c in children) {
      if (c.lat < minLat) minLat = c.lat;
      if (c.lat > maxLat) maxLat = c.lat;
      if (c.lng < minLng) minLng = c.lng;
      if (c.lng > maxLng) maxLng = c.lng;
    }
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    return List.generate(children.length, (i) {
      final c = children[i];
      final isSelected = i == selectedIndex;

      double offsetX = 0;
      double offsetY = 0;

      if (maxLat - minLat > 0.0001 || maxLng - minLng > 0.0001) {
        offsetX = (c.lng - centerLng) * 50000;
        offsetY = -(c.lat - centerLat) * 50000;
      } else {
        const spread = 60.0;
        offsetX = spread * (i % 3 - 1).toDouble();
        offsetY = spread * (i ~/ 3 - (children.length > 3 ? 1 : 0)).toDouble();
      }

      return Center(
        child: Transform.translate(
          offset: Offset(
            offsetX.clamp(-120.0, 120.0),
            offsetY.clamp(-120.0, 120.0),
          ),
          child: _ChildMarker(
            label: c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
            name: c.name,
            isSelected: isSelected,
            avatarUrl: c.avatarUrl,
            onTap: () => onChildTapped?.call(i),
          ),
        ),
      );
    });
  }
}

class _ChildMarker extends StatelessWidget {
  const _ChildMarker({
    required this.label,
    required this.name,
    required this.isSelected,
    this.avatarUrl,
    this.onTap,
  });
  final String label;
  final String name;
  final bool isSelected;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 56.0 : 46.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.4)
                      : Colors.black26,
                  blurRadius: isSelected ? 12 : 6,
                ),
              ],
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 3)
                  : null,
            ),
            child: AvatarCircle(
              initials: label,
              size: size,
              color: AppColors.primary,
              image: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                name.length > 8 ? name.substring(0, 8).toUpperCase() : name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              shape: BoxShape.circle,
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
