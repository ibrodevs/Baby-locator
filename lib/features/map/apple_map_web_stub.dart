import 'package:flutter/material.dart';

import '../../core/providers/session_providers.dart';
import 'map_models.dart';

class AppleMapWeb extends StatelessWidget {
  const AppleMapWeb({
    super.key,
    required this.latitude,
    required this.longitude,
    this.children = const [],
    this.parentLocation,
    this.onChildTapped,
  });

  final double latitude;
  final double longitude;
  final List<ChildLocation> children;
  final ParentMapLocation? parentLocation;
  final ValueChanged<int>? onChildTapped;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
