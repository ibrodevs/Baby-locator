import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:http/http.dart' as http;
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/local_avatar_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import 'map_models.dart';
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
    this.parentLocation,
    this.selectedIndex,
    this.followTarget = true,
    this.onChildTapped,
    this.onCameraMove,
    this.onUserCameraMoveStarted,
    this.path = const [],
    this.pathColor,
    this.pathWidth = 6,
    this.ghostPath = const [],
    this.circles = const [],
  });

  final double latitude;
  final double longitude;
  final List<ChildLocation> children;
  final ParentMapLocation? parentLocation;
  final int? selectedIndex;
  final bool followTarget;
  final ValueChanged<int>? onChildTapped;
  final Function(double lat, double lng)? onCameraMove;
  final VoidCallback? onUserCameraMoveStarted;

  /// Optional polyline drawn over the map (e.g. movement history). When
  /// empty, no line is drawn.
  final List<MapLatLng> path;
  final Color? pathColor;
  final int pathWidth;

  /// Remaining (future) part of the path drawn faintly in the background.
  final List<MapLatLng> ghostPath;

  /// Optional circles drawn over the map (e.g. safe zones).
  final List<MapCircle> circles;

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  am.AppleMapController? _appleCtrl;
  gm.GoogleMapController? _googleCtrl;
  final Map<int, gm.BitmapDescriptor> _googleMarkers = {};
  final Map<int, am.BitmapDescriptor> _appleMarkers = {};
  gm.BitmapDescriptor? _googleParentMarker;
  am.BitmapDescriptor? _appleParentMarker;
  final Map<String, ui.Image> _avatarCache = {};
  bool _isProgrammaticCameraMove = false;
  String _markerSignature = '';
  static final Set<Factory<OneSequenceGestureRecognizer>>
      _mapGestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    final signature = _buildMarkerSignature(widget.children);
    if (widget.children.isEmpty && widget.parentLocation == null) {
      if (!mounted) return;
      setState(() {
        _markerSignature = signature;
        _googleMarkers.clear();
        _appleMarkers.clear();
        _googleParentMarker = null;
        _appleParentMarker = null;
      });
      return;
    }

    final nextGoogleMarkers = <int, gm.BitmapDescriptor>{};
    final nextAppleMarkers = <int, am.BitmapDescriptor>{};
    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      final key = child.childId ?? i;
      final bytes = await _generateMarkerBytes(child);
      nextGoogleMarkers[key] = gm.BitmapDescriptor.fromBytes(bytes);
      nextAppleMarkers[key] = am.BitmapDescriptor.fromBytes(bytes);
    }

    gm.BitmapDescriptor? nextGoogleParentMarker;
    am.BitmapDescriptor? nextAppleParentMarker;
    if (widget.parentLocation != null) {
      final bytes = await _generateParentMarkerBytes(widget.parentLocation!);
      nextGoogleParentMarker = gm.BitmapDescriptor.fromBytes(bytes);
      nextAppleParentMarker = am.BitmapDescriptor.fromBytes(bytes);
    }

    if (!mounted) return;
    setState(() {
      _markerSignature = signature;
      _googleMarkers
        ..clear()
        ..addAll(nextGoogleMarkers);
      _appleMarkers
        ..clear()
        ..addAll(nextAppleMarkers);
      _googleParentMarker = nextGoogleParentMarker;
      _appleParentMarker = nextAppleParentMarker;
    });
  }

  String _buildMarkerSignature(List<ChildLocation> children) {
    final childSignature = children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      return [
        child.childId ?? index,
        child.name,
        child.avatarUrl ?? '',
        child.lat.toStringAsFixed(5),
        child.lng.toStringAsFixed(5),
      ].join('|');
    }).join('||');
    final parent = widget.parentLocation;
    final parentSignature = parent == null
        ? ''
        : [
            parent.latitude.toStringAsFixed(5),
            parent.longitude.toStringAsFixed(5),
            parent.label,
          ].join('|');
    return '$childSignature##$parentSignature';
  }

  bool _markersNeedReload(covariant AdaptiveMap old) {
    return _buildMarkerSignature(old.children) !=
        _buildMarkerSignature(widget.children);
  }

  @override
  void didUpdateWidget(covariant AdaptiveMap old) {
    super.didUpdateWidget(old);
    if (_markersNeedReload(old) || _markerSignature.isEmpty) {
      _loadCustomMarkers();
    }
    final targetChanged =
        old.latitude != widget.latitude || old.longitude != widget.longitude;
    if (widget.followTarget && (targetChanged || !old.followTarget)) {
      _animateToTarget();
    }
  }

  Future<ui.Image?> _loadAvatarImage(String source) async {
    if (_avatarCache.containsKey(source)) return _avatarCache[source];
    try {
      Uint8List bytes;
      if (source.startsWith('http://') || source.startsWith('https://')) {
        final response = await http.get(Uri.parse(source));
        if (response.statusCode != 200) return null;
        bytes = response.bodyBytes;
      } else {
        final file = File(source);
        if (!file.existsSync()) return null;
        bytes = await file.readAsBytes();
      }
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _avatarCache[source] = frame.image;
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
    const double totalHeight = size + labelHeight + 16;

    ui.Image? avatarImage;
    if (child.avatarUrl != null && child.avatarUrl!.isNotEmpty) {
      avatarImage = await _loadAvatarImage(child.avatarUrl!);
    }

    final borderPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(radius, radius + 2), radius, shadowPaint);
    canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);

    if (avatarImage != null) {
      canvas.save();
      final clipPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: const Offset(radius, radius),
            radius: radius - borderWidth,
          ),
        );
      canvas.clipPath(clipPath);

      final srcRect = Rect.fromLTWH(
        0,
        0,
        avatarImage.width.toDouble(),
        avatarImage.height.toDouble(),
      );
      final dstRect = Rect.fromCircle(
        center: const Offset(radius, radius),
        radius: radius - borderWidth,
      );
      canvas.drawImageRect(avatarImage, srcRect, dstRect, Paint());
      canvas.restore();
    } else {
      final bgPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(
        const Offset(radius, radius),
        radius - borderWidth,
        bgPaint,
      );

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
        Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
      );
    }

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

    const labelY = size + 4;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(radius, labelY + labelHeight / 2),
        width: namePainter.width + 16,
        height: labelHeight,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      labelRect,
      Paint()..color = AppColors.primary.withValues(alpha: 0.85),
    );
    namePainter.paint(
      canvas,
      Offset(radius - namePainter.width / 2, labelY + 4),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), totalHeight.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _generateParentMarkerBytes(
    ParentMapLocation parentLocation,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double width = 164.0;
    const double height = 104.0;
    const double dotRadius = 16.0;
    const double pinBottomY = 88.0;
    const double labelHeight = 30.0;

    final labelPainter = TextPainter(
      text: TextSpan(
        text: parentLocation.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: width - 24);

    final labelWidth =
        (labelPainter.width + 24).clamp(72.0, width).toDouble();
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(width / 2, labelHeight / 2),
        width: labelWidth,
        height: labelHeight,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(
      labelRect,
      Paint()..color = AppColors.success.withValues(alpha: 0.94),
    );
    labelPainter.paint(
      canvas,
      Offset((width - labelPainter.width) / 2, 7),
    );

    final linePaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(width / 2, labelHeight),
      const Offset(width / 2, pinBottomY - dotRadius),
      linePaint,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
      const Offset(width / 2, pinBottomY + 2),
      dotRadius,
      shadowPaint,
    );
    canvas.drawCircle(
      const Offset(width / 2, pinBottomY),
      dotRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(width / 2, pinBottomY),
      dotRadius - 4,
      Paint()..color = AppColors.success,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  void _animateToTarget() {
    _isProgrammaticCameraMove = true;
    _appleCtrl?.animateCamera(
      am.CameraUpdate.newLatLng(am.LatLng(widget.latitude, widget.longitude)),
    );
    _googleCtrl?.animateCamera(
      gm.CameraUpdate.newLatLng(gm.LatLng(widget.latitude, widget.longitude)),
    );
  }

  void _handleCameraMoveStarted() {
    if (_isProgrammaticCameraMove) return;
    widget.onUserCameraMoveStarted?.call();
  }

  void _handleCameraIdle() {
    _isProgrammaticCameraMove = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildAppleMap();
    }

    if (kIsWeb) {
      return AppleMapWeb(
        latitude: widget.latitude,
        longitude: widget.longitude,
        children: widget.children,
        parentLocation: widget.parentLocation,
        onChildTapped: widget.onChildTapped,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildGoogleMap();
    }

    return _PaintedMap(
      children: widget.children,
      parentLocation: widget.parentLocation,
      selectedIndex: widget.selectedIndex,
      onChildTapped: widget.onChildTapped,
    );
  }

  Widget _buildAppleMap() {
    final t = S.of(context);
    final pos = am.LatLng(widget.latitude, widget.longitude);
    final annotations = <am.Annotation>{};
    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      final key = c.childId ?? i;
      annotations.add(
        am.Annotation(
          annotationId: am.AnnotationId('child_$key'),
          position: am.LatLng(c.lat, c.lng),
          icon: _appleMarkers[key] ?? am.BitmapDescriptor.defaultAnnotation,
          infoWindow: am.InfoWindow(
            title: c.name,
            snippet: t.batteryPercent(c.battery),
          ),
          onTap: () => widget.onChildTapped?.call(i),
        ),
      );
    }

    final parentLocation = widget.parentLocation;
    if (parentLocation != null) {
      annotations.add(
        am.Annotation(
          annotationId: am.AnnotationId('parent_location'),
          position: am.LatLng(parentLocation.latitude, parentLocation.longitude),
          icon: _appleParentMarker ?? am.BitmapDescriptor.defaultAnnotation,
          infoWindow: am.InfoWindow(title: parentLocation.label),
        ),
      );
    }

    final polylines = <am.Polyline>{};
    if (widget.ghostPath.length >= 2) {
      polylines.add(
        am.Polyline(
          polylineId: am.PolylineId('ghost_path'),
          color: const Color(0x40888888),
          width: widget.pathWidth,
          points: [
            for (final p in widget.ghostPath)
              am.LatLng(p.latitude, p.longitude),
          ],
        ),
      );
    }
    if (widget.path.length >= 2) {
      polylines.add(
        am.Polyline(
          polylineId: am.PolylineId('history_path'),
          color: widget.pathColor ?? AppColors.primary,
          width: widget.pathWidth,
          points: [
            for (final p in widget.path) am.LatLng(p.latitude, p.longitude),
          ],
        ),
      );
    }

    final appleCircles = <am.Circle>{
      for (final c in widget.circles)
        am.Circle(
          circleId: am.CircleId(c.id),
          center: am.LatLng(c.center.latitude, c.center.longitude),
          radius: c.radiusMeters,
          strokeColor: c.strokeColor,
          fillColor: c.fillColor,
          strokeWidth: c.strokeWidth,
        ),
    };

    return am.AppleMap(
      initialCameraPosition: am.CameraPosition(target: pos, zoom: 14),
      compassEnabled: false,
      onMapCreated: (c) => _appleCtrl = c,
      gestureRecognizers: _mapGestureRecognizers,
      onCameraMoveStarted: _handleCameraMoveStarted,
      onCameraMove: widget.onCameraMove != null
          ? (pos) =>
              widget.onCameraMove!(pos.target.latitude, pos.target.longitude)
          : null,
      onCameraIdle: _handleCameraIdle,
      annotations: annotations,
      polylines: polylines,
      circles: appleCircles,
    );
  }

  Widget _buildGoogleMap() {
    final t = S.of(context);
    final pos = gm.LatLng(widget.latitude, widget.longitude);
    final markers = <gm.Marker>{};
    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      final key = c.childId ?? i;
      markers.add(
        gm.Marker(
          markerId: gm.MarkerId('child_$key'),
          position: gm.LatLng(c.lat, c.lng),
          icon: _googleMarkers[key] ?? gm.BitmapDescriptor.defaultMarker,
          infoWindow: gm.InfoWindow(
            title: c.name,
            snippet: t.batteryPercent(c.battery),
          ),
          onTap: () => widget.onChildTapped?.call(i),
        ),
      );
    }

    final parentLocation = widget.parentLocation;
    if (parentLocation != null) {
      markers.add(
        gm.Marker(
          markerId: const gm.MarkerId('parent_location'),
          position: gm.LatLng(
            parentLocation.latitude,
            parentLocation.longitude,
          ),
          icon: _googleParentMarker ??
              gm.BitmapDescriptor.defaultMarkerWithHue(
                gm.BitmapDescriptor.hueAzure,
              ),
          infoWindow: gm.InfoWindow(title: parentLocation.label),
        ),
      );
    }

    final polylines = <gm.Polyline>{};
    if (widget.ghostPath.length >= 2) {
      polylines.add(
        gm.Polyline(
          polylineId: const gm.PolylineId('ghost_path'),
          color: const Color(0x40888888),
          width: widget.pathWidth,
          points: [
            for (final p in widget.ghostPath)
              gm.LatLng(p.latitude, p.longitude),
          ],
          jointType: gm.JointType.round,
          startCap: gm.Cap.roundCap,
          endCap: gm.Cap.roundCap,
          geodesic: true,
        ),
      );
    }
    if (widget.path.length >= 2) {
      polylines.add(
        gm.Polyline(
          polylineId: const gm.PolylineId('history_path'),
          color: widget.pathColor ?? AppColors.primary,
          width: widget.pathWidth,
          points: [
            for (final p in widget.path) gm.LatLng(p.latitude, p.longitude),
          ],
          jointType: gm.JointType.round,
          startCap: gm.Cap.roundCap,
          endCap: gm.Cap.roundCap,
          geodesic: true,
        ),
      );
    }

    final googleCircles = <gm.Circle>{
      for (final c in widget.circles)
        gm.Circle(
          circleId: gm.CircleId(c.id),
          center: gm.LatLng(c.center.latitude, c.center.longitude),
          radius: c.radiusMeters,
          strokeColor: c.strokeColor,
          fillColor: c.fillColor,
          strokeWidth: c.strokeWidth,
        ),
    };

    return gm.GoogleMap(
      initialCameraPosition: gm.CameraPosition(target: pos, zoom: 14),
      onMapCreated: (c) => _googleCtrl = c,
      gestureRecognizers: _mapGestureRecognizers,
      onCameraMoveStarted: _handleCameraMoveStarted,
      onCameraMove: widget.onCameraMove != null
          ? (pos) =>
              widget.onCameraMove!(pos.target.latitude, pos.target.longitude)
          : null,
      onCameraIdle: _handleCameraIdle,
      markers: markers,
      polylines: polylines,
      circles: googleCircles,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

class _PaintedMap extends StatelessWidget {
  const _PaintedMap({
    required this.children,
    this.parentLocation,
    this.selectedIndex,
    this.onChildTapped,
  });

  final List<ChildLocation> children;
  final ParentMapLocation? parentLocation;
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
              child: parentLocation != null
                  ? _ParentMarker(label: parentLocation!.label)
                  : _ChildMarker(
                      label: '?',
                      name: '',
                      isSelected: false,
                      onTap: null,
                    ),
            )
          else ...[
            if (parentLocation != null)
              Positioned(
                left: 24,
                top: 28,
                child: _ParentMarker(label: parentLocation!.label),
              ),
            ..._positionedMarkers(context),
          ],
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
              image: avatarImageProvider(avatarUrl),
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
                name.length > 8
                    ? name.substring(0, 8).toUpperCase()
                    : name.toUpperCase(),
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

class _ParentMarker extends StatelessWidget {
  const _ParentMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 4,
          height: 18,
          color: AppColors.success,
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
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
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.5),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
