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
    this.avatarUrl,
  });

  final int id;
  final String username;
  final UserRole role;
  final String displayName;
  final int? parentId;
  final String? avatarUrl;

  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
        id: j['id'] as int,
        username: j['username'] as String,
        role: _roleFrom(j['role'] as String?),
        displayName: (j['display_name'] as String?) ?? '',
        parentId: j['parent'] as int?,
        avatarUrl: j['avatar_url'] as String?,
      );

  SessionUser copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
  }) =>
      SessionUser(
        id: id,
        username: username ?? this.username,
        role: role,
        displayName: displayName ?? this.displayName,
        parentId: parentId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
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

  SessionState copyWith(
          {SessionUser? user,
          bool? loading,
          String? error,
          bool clearUser = false}) =>
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

  Future<void> registerChild({
    required String code,
    required String username,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await ApiClient.instance.registerChildWithCode(
        code: code,
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

  void updateAvatar(String url) {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(avatarUrl: url));
    }
  }

  void updateUser(SessionUser user) {
    state = state.copyWith(user: user);
  }

  Future<void> updateProfile({
    String? username,
    String? displayName,
  }) async {
    if (state.user == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await ApiClient.instance.updateProfile(
        username: username,
        displayName: displayName,
      );
      state = SessionState(
        user: SessionUser.fromJson(data),
      );
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

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
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
    this.childId,
    this.avatarUrl,
  });

  final String name;
  final double lat;
  final double lng;
  final String address;
  final int battery;
  final DateTime updatedAt;
  final bool active;
  final int? childId;
  final String? avatarUrl;

  ChildLocation copyWith({
    String? name,
    double? lat,
    double? lng,
    String? address,
    int? battery,
    DateTime? updatedAt,
    bool? active,
    int? childId,
    String? avatarUrl,
  }) =>
      ChildLocation(
        name: name ?? this.name,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
        battery: battery ?? this.battery,
        updatedAt: updatedAt ?? this.updatedAt,
        active: active ?? this.active,
        childId: childId ?? this.childId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

class ChildLocationNotifier extends StateNotifier<ChildLocation?> {
  ChildLocationNotifier() : super(null);

  void setFromApi(Map<String, dynamic> j,
      {String name = 'Child', int? childId, String? avatarUrl}) {
    state = ChildLocation(
      name: name,
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      address: (j['address'] as String?) ?? '',
      battery: (j['battery'] as int?) ?? 0,
      updatedAt:
          DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      active: (j['active'] as bool?) ?? true,
      childId: childId,
      avatarUrl: avatarUrl,
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

// All children locations for the map (list of ChildLocation)
class AllChildrenLocationsNotifier extends StateNotifier<List<ChildLocation>> {
  AllChildrenLocationsNotifier() : super([]);

  void setFromApi(List<dynamic> data) {
    final list = <ChildLocation>[];
    for (final entry in data) {
      final childData = entry['child'] as Map<String, dynamic>;
      final locData = entry['location'] as Map<String, dynamic>?;
      if (locData == null) continue;
      final name = ((childData['display_name'] as String?)?.isNotEmpty ?? false)
          ? childData['display_name'] as String
          : childData['username'] as String;
      list.add(ChildLocation(
        name: name,
        lat: (locData['lat'] as num).toDouble(),
        lng: (locData['lng'] as num).toDouble(),
        address: (locData['address'] as String?) ?? '',
        battery: (locData['battery'] as int?) ?? 0,
        updatedAt: DateTime.tryParse(locData['created_at'] as String? ?? '') ??
            DateTime.now(),
        active: (locData['active'] as bool?) ?? true,
        childId: childData['id'] as int,
        avatarUrl: childData['avatar_url'] as String?,
      ));
    }
    state = list;
  }

  void clear() => state = [];
}

final allChildrenLocationsProvider =
    StateNotifierProvider<AllChildrenLocationsNotifier, List<ChildLocation>>(
  (ref) => AllChildrenLocationsNotifier(),
);
