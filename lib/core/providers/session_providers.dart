import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';

enum UserRole { none, parent, child }

class SessionUser {
  SessionUser({
    required this.id,
    required this.username,
    required this.role,
    required this.displayName,
    this.parentId,
  });

  final int id;
  final String username;
  final UserRole role;
  final String displayName;
  final int? parentId;

  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
        id: j['id'] as int,
        username: j['username'] as String,
        role: _roleFrom(j['role'] as String?),
        displayName: (j['display_name'] as String?) ?? '',
        parentId: j['parent'] as int?,
      );

  static UserRole _roleFrom(String? r) {
    switch (r) {
      case 'parent':
        return UserRole.parent;
      case 'child':
        return UserRole.child;
      default:
        return UserRole.none;
    }
  }
}

class SessionState {
  SessionState({this.user, this.loading = false, this.error});
  final SessionUser? user;
  final bool loading;
  final String? error;

  SessionState copyWith({SessionUser? user, bool? loading, String? error, bool clearUser = false}) =>
      SessionState(
        user: clearUser ? null : user ?? this.user,
        loading: loading ?? this.loading,
        error: error,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState());

  Future<void> bootstrap() async {
    await ApiClient.instance.loadToken();
    if (ApiClient.instance.token == null) return;
    try {
      final j = await ApiClient.instance.me();
      state = state.copyWith(user: SessionUser.fromJson(j));
    } catch (_) {
      await ApiClient.instance.logout();
    }
  }

  Future<void> registerParent({
    required String username,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await ApiClient.instance.registerParent(
        username: username,
        password: password,
        displayName: displayName,
      );
      state = SessionState(
          user: SessionUser.fromJson(data['user'] as Map<String, dynamic>));
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await ApiClient.instance.login(
        username: username,
        password: password,
      );
      state = SessionState(
          user: SessionUser.fromJson(data['user'] as Map<String, dynamic>));
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.logout();
    state = SessionState();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(),
);

// ===== Child location (local, for the Child screen + parent's map) =====

class ChildLocation {
  ChildLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.battery,
    required this.updatedAt,
    required this.active,
  });

  final String name;
  final double lat;
  final double lng;
  final String address;
  final int battery;
  final DateTime updatedAt;
  final bool active;

  ChildLocation copyWith({
    String? name,
    double? lat,
    double? lng,
    String? address,
    int? battery,
    DateTime? updatedAt,
    bool? active,
  }) =>
      ChildLocation(
        name: name ?? this.name,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
        battery: battery ?? this.battery,
        updatedAt: updatedAt ?? this.updatedAt,
        active: active ?? this.active,
      );
}

class ChildLocationNotifier extends StateNotifier<ChildLocation?> {
  ChildLocationNotifier() : super(null);

  void setFromApi(Map<String, dynamic> j, {String name = 'Child'}) {
    state = ChildLocation(
      name: name,
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      address: (j['address'] as String?) ?? '',
      battery: (j['battery'] as int?) ?? 0,
      updatedAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
          DateTime.now(),
      active: (j['active'] as bool?) ?? true,
    );
  }

  void setLocal({
    required double lat,
    required double lng,
    String? address,
    int? battery,
    bool? active,
    String? name,
  }) {
    state = ChildLocation(
      name: name ?? state?.name ?? 'Child',
      lat: lat,
      lng: lng,
      address: address ?? state?.address ?? '',
      battery: battery ?? state?.battery ?? 100,
      updatedAt: DateTime.now(),
      active: active ?? true,
    );
  }

  void clear() => state = null;
}

final childLocationProvider =
    StateNotifierProvider<ChildLocationNotifier, ChildLocation?>(
  (ref) => ChildLocationNotifier(),
);

// Selected child for parent map
final selectedChildIdProvider = StateProvider<int?>((_) => null);
