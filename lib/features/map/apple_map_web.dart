import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../core/providers/session_providers.dart';

class AppleMapWeb extends StatefulWidget {
  const AppleMapWeb({
    super.key,
    required this.latitude,
    required this.longitude,
    this.children = const [],
    this.onChildTapped,
  });

  final double latitude;
  final double longitude;
  final List<ChildLocation> children;
  final ValueChanged<int>? onChildTapped;

  @override
  State<AppleMapWeb> createState() => _AppleMapWebState();
}

class _AppleMapWebState extends State<AppleMapWeb> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'apple-map-${DateTime.now().millisecondsSinceEpoch}';

    // Регистрируем фабрику для создания HTML элемента карты
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final div = web.HTMLDivElement()
        ..id = _viewId
        ..style.width = '100%'
        ..style.height = '100%';

      // JavaScript код для инициализации MapKit
      final script = web.HTMLScriptElement()
        ..text = '''
          if (typeof mapkit !== 'undefined') {
            mapkit.init({
              authorizationCallback: function(done) {
                // ВСТАВЬТЕ ВАШ MAPKIT JS TOKEN ЗДЕСЬ
                done("YOUR_APPLE_MAPKIT_JS_TOKEN");
              }
            });

            var region = new mapkit.CoordinateRegion(
              new mapkit.Coordinate(${widget.latitude}, ${widget.longitude}),
              new mapkit.CoordinateSpan(0.02, 0.02)
            );
            var map = new mapkit.Map("$_viewId");
            map.region = region;

            // Добавляем маркеры детей
            ${_generateMarkersJS()}
          }
        ''';
      
      div.append(script);
      return div;
    });
  }

  String _generateMarkersJS() {
    final buffer = StringBuffer();
    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      buffer.writeln('''
        var childPos$i = new mapkit.Coordinate(${c.lat}, ${c.lng});
        var annotation$i = new mapkit.MarkerAnnotation(childPos$i, {
          title: "${c.name}",
          glyphText: "${c.name.isNotEmpty ? c.name[0].toUpperCase() : '?'}",
          color: "#1C62F0"
        });
        annotation$i.addEventListener("select", function() {
          // Вызов колбэка обратно во Flutter через событие или канал
          window.parent.postMessage({type: 'childTapped', index: $i}, '*');
        });
        map.addAnnotation(annotation$i);
      ''');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
