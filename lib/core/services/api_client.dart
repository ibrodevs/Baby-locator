import 'dart:convert';
import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the Django backend.
class ApiConfig {
  static const String _defineBase =
      String.fromEnvironment('API_BASE', defaultValue: '');
  static const String _defaultBase = 'https://backend21.pythonanywhere.com';

  static String get baseUrl {
    if (_defineBase.isNotEmpty) return _defineBase;
    if (kIsWeb) return _defaultBase;
    if (Platform.isAndroid) return _defaultBase;
    return _defaultBase;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;
  String? _sessionRole;
  int? _sessionUserId;
  String? get token => _token;
  String? get sessionRole => _sessionRole;
  int? get sessionUserId => _sessionUserId;
  bool get hasChildSession => _token != null && _sessionRole == 'child';

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _sessionRole = prefs.getString('auth_role');
    _sessionUserId = prefs.getInt('auth_user_id');
  }

  Future<void> _saveSession(
    String? t, {
    Map<String, dynamic>? user,
  }) async {
    _token = t;
    _sessionRole = user?['role'] as String?;
    final rawUserId = user?['id'];
    if (rawUserId is int) {
      _sessionUserId = rawUserId;
    } else if (rawUserId != null) {
      _sessionUserId = int.tryParse('$rawUserId');
    } else {
      _sessionUserId = null;
    }
    final prefs = await SharedPreferences.getInstance();
    if (t == null) {
      await prefs.remove('auth_token');
      await prefs.remove('auth_role');
      await prefs.remove('auth_user_id');
    } else {
      await prefs.setString('auth_token', t);
      if (_sessionRole != null && _sessionRole!.isNotEmpty) {
        await prefs.setString('auth_role', _sessionRole!);
      } else {
        await prefs.remove('auth_role');
      }
      if (_sessionUserId != null) {
        await prefs.setInt('auth_user_id', _sessionUserId!);
      } else {
        await prefs.remove('auth_user_id');
      }
    }
  }

  Future<void> persistAuthenticatedUser(Map<String, dynamic> user) async {
    await _saveSession(_token, user: user);
  }

  Future<bool> ensureChildSession() async {
    await loadToken();
    if (_token == null) return false;
    if (_sessionRole == 'child') return true;
    if (_sessionRole != null && _sessionRole != 'child') return false;
    try {
      final user = await me();
      await persistAuthenticatedUser(user);
    } catch (_) {
      return false;
    }
    return hasChildSession;
  }

  Map<String, String> _headers({bool json = true}) {
    return {
      if (json) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Token $_token',
    };
  }

  Uri _u(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final r =
        await http.post(_u(path), headers: _headers(), body: jsonEncode(body));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patch(
      String path, Map<String, dynamic> body) async {
    final r =
        await http.patch(_u(path), headers: _headers(), body: jsonEncode(body));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    final r = await http.delete(_u(path), headers: _headers(json: false));
    _decode(r);
  }

  Future<dynamic> _get(String path) async {
    final r = await http.get(_u(path), headers: _headers(json: false));
    return _decode(r);
  }

  dynamic _decode(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      return jsonDecode(r.body);
    }
    String msg = r.body;
    try {
      final decoded = jsonDecode(r.body);
      msg = decoded is Map ? decoded.values.first.toString() : msg;
    } catch (_) {}
    throw ApiException(r.statusCode, msg);
  }

  // === Auth ===
  Future<Map<String, dynamic>> registerParent({
    required String username,
    required String password,
    String? displayName,
  }) async {
    final data = await _post('/api/auth/register/', {
      'username': username,
      'password': password,
      if (displayName != null) 'display_name': displayName,
    });
    await _saveSession(
      data['token'] as String,
      user: data['user'] as Map<String, dynamic>?,
    );
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final data = await _post('/api/auth/login/', {
      'username': username,
      'password': password,
    });
    await _saveSession(
      data['token'] as String,
      user: data['user'] as Map<String, dynamic>?,
    );
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    return (await _get('/api/auth/me/')) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? displayName,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (displayName != null) body['display_name'] = displayName;
    final data = await _patch('/api/auth/me/', body);
    await persistAuthenticatedUser(data);
    return data;
  }

  Future<void> logout() async {
    await _saveSession(null);
  }

  // === Invite Code ===
  Future<Map<String, dynamic>> generateInviteCode({int? childId}) async {
    return await _post('/api/auth/invite/', {
      if (childId != null) 'child_id': childId,
    });
  }

  Future<Map<String, dynamic>> getInviteCode({int? childId}) async {
    final uri = _u('/api/auth/invite/').replace(
      queryParameters:
          childId == null ? null : <String, String>{'child_id': '$childId'},
    );
    final r = await http.get(uri, headers: _headers(json: false));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerChildWithCode({
    required String code,
    String? displayName,
  }) async {
    final data = await _post('/api/auth/register-child/', {
      'code': code,
      if (displayName != null) 'display_name': displayName,
    });
    await _saveSession(
      data['token'] as String,
      user: data['user'] as Map<String, dynamic>?,
    );
    return data;
  }

  // === Children ===
  Future<List<dynamic>> listChildren() async {
    return (await _get('/api/auth/children/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createChild({
    String? username,
    String? password,
    String? displayName,
    String? gender,
  }) async {
    return await _post('/api/auth/children/', {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (displayName != null) 'display_name': displayName,
      if (gender != null) 'gender': gender,
    });
  }

  Future<Map<String, dynamic>> updateChild(int childId,
      {String? displayName, String? gender}) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (gender != null) body['gender'] = gender;
    final r = await http.patch(
      _u('/api/auth/children/$childId/'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decode(r) as Map<String, dynamic>;
  }

  Future<void> deleteChild(int childId) async {
    await _delete('/api/auth/children/$childId/');
  }

  Future<Map<String, dynamic>> uploadChildAvatar(
      int childId, File imageFile) async {
    final request = http.MultipartRequest(
        'POST', _u('/api/auth/children/$childId/avatar/'));
    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response) as Map<String, dynamic>;
  }

  // === Avatar ===
  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final request = http.MultipartRequest('POST', _u('/api/auth/avatar/'));
    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response) as Map<String, dynamic>;
  }

  // === SOS ===
  Future<Map<String, dynamic>> sendSos({
    double? lat,
    double? lng,
    String? address,
  }) async {
    return await _post('/api/sos/', {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (address != null) 'address': address,
    });
  }

  // === Location ===
  Future<Map<String, dynamic>> shareLocation({
    required double lat,
    required double lng,
    String? address,
    int? battery,
    bool? charging,
    bool? active,
  }) async {
    return await _post('/api/locations/', {
      'lat': lat,
      'lng': lng,
      if (address != null) 'address': address,
      if (battery != null) 'battery': battery,
      if (charging != null) 'charging': charging,
      if (active != null) 'active': active,
    });
  }

  Future<Map<String, dynamic>?> childLatest(int childId) async {
    try {
      return (await _get('/api/children/$childId/location/'))
          as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<dynamic>> childHistory(int childId) async {
    return (await _get('/api/children/$childId/history/')) as List<dynamic>;
  }

  /// Get latest location for ALL children in one call (parent only).
  Future<List<dynamic>> allChildrenLocations() async {
    return (await _get('/api/children/locations/')) as List<dynamic>;
  }

  // === Safe Zones ===
  Future<List<dynamic>> listSafeZones() async {
    return (await _get('/api/safe-zones/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSafeZone({
    required String name,
    required double lat,
    required double lng,
    required double radius,
    bool active = true,
    String scheduleType = 'always',
    List<int> activeDays = const [],
  }) async {
    return await _post('/api/safe-zones/', {
      'name': name,
      'lat': lat,
      'lng': lng,
      'radius': radius,
      'active': active,
      'schedule_type': scheduleType,
      'active_days': activeDays,
    });
  }

  Future<Map<String, dynamic>> updateSafeZone(
    int id, {
    String? name,
    double? lat,
    double? lng,
    double? radius,
    bool? active,
    String? scheduleType,
    List<int>? activeDays,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null) 'radius': radius,
      if (active != null) 'active': active,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (activeDays != null) 'active_days': activeDays,
    };
    return await _patch('/api/safe-zones/$id/', body);
  }

  Future<void> deleteSafeZone(int id) async {
    await _delete('/api/safe-zones/$id/');
  }

  // === Activity & Safety ===
  Future<List<dynamic>> childActivity(int childId) async {
    return (await _get('/api/children/$childId/activity/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> childSafetyScore(int childId) async {
    return (await _get('/api/children/$childId/safety-score/'))
        as Map<String, dynamic>;
  }

  // === Device Stats ===
  Future<Map<String, dynamic>> syncDeviceStats(
      Map<String, dynamic> payload) async {
    return await _post('/api/device-stats/sync/', payload);
  }

  Future<Map<String, dynamic>> childStatsSummary(
    int childId, {
    DateTime? date,
    DateTime? month,
  }) async {
    final params = <String, String>{};
    if (date != null) {
      params['date'] = date.toIso8601String().split('T').first;
    }
    if (month != null) {
      final monthString =
          '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
      params['month'] = monthString;
    }
    final uri = _u('/api/children/$childId/stats/').replace(
      queryParameters: params.isEmpty ? null : params,
    );
    final r = await http.get(uri, headers: _headers(json: false));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setChildAppLimit({
    required int childId,
    required String packageName,
    required String appName,
    required int dailyLimitMinutes,
    required bool enabled,
  }) async {
    return await _post('/api/children/$childId/app-limits/', {
      'package_name': packageName,
      'app_name': appName,
      'daily_limit_minutes': dailyLimitMinutes,
      'enabled': enabled,
    });
  }

  // === Blocked Apps ===
  Future<List<dynamic>> getBlockedApps(int childId) async {
    return (await _get('/api/children/$childId/blocked-apps/'))
        as List<dynamic>;
  }

  Future<Map<String, dynamic>> blockApp(
    int childId, {
    required String packageName,
    required String appName,
  }) async {
    return await _post('/api/children/$childId/blocked-apps/', {
      'package_name': packageName,
      'app_name': appName,
    });
  }

  Future<void> unblockApp(int childId, int blockedId) async {
    await _delete('/api/children/$childId/blocked-apps/$blockedId/');
  }

  // === FCM Token ===
  Future<void> registerFcmToken(String fcmToken) async {
    await _post('/api/auth/fcm-token/', {'fcm_token': fcmToken});
  }

  // === Remote Device Commands ===
  Future<Map<String, dynamic>> triggerLoud(int childId) async {
    return await _post('/api/children/$childId/device-commands/', {
      'command_type': 'loud',
    });
  }

  Future<Map<String, dynamic>> stopLoud(int childId) async {
    return await _post('/api/children/$childId/device-commands/', {
      'command_type': 'loud_stop',
    });
  }

  Future<Map<String, dynamic>> startAround(int childId) async {
    return await _post('/api/children/$childId/device-commands/', {
      'command_type': 'around_start',
    });
  }

  Future<Map<String, dynamic>> stopAround(
    int childId, {
    required String sessionToken,
  }) async {
    return await _post('/api/children/$childId/device-commands/', {
      'command_type': 'around_stop',
      'payload': {
        'session_token': sessionToken,
      },
    });
  }

  Future<List<dynamic>> pendingDeviceCommands() async {
    return (await _get('/api/device-commands/pending/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> completeDeviceCommand(
    int commandId, {
    required bool success,
    String? errorMessage,
  }) async {
    return await _post('/api/device-commands/$commandId/complete/', {
      'success': success,
      if (errorMessage != null && errorMessage.isNotEmpty)
        'error_message': errorMessage,
    });
  }

  Future<Map<String, dynamic>> uploadAroundAudio({
    required File audioFile,
    required String sessionToken,
    int durationSeconds = 0,
  }) async {
    final request = http.MultipartRequest('POST', _u('/api/around-audio/'));
    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }
    request.fields['session_token'] = sessionToken;
    request.fields['duration_seconds'] = '$durationSeconds';
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFile.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response) as Map<String, dynamic>;
  }

  /// Downloads the raw audio bytes for an around clip.
  Future<List<int>> downloadAroundAudio(int clipId) async {
    final r = await http.get(
      _u('/api/around-audio/$clipId/stream/'),
      headers: _headers(json: false),
    );
    if (r.statusCode != 200) {
      throw ApiException(r.statusCode, 'Failed to download audio clip');
    }
    return r.bodyBytes;
  }

  Future<Map<String, dynamic>?> latestAroundAudio(
    int childId, {
    required String sessionToken,
    int? afterId,
  }) async {
    final params = <String, String>{
      'session_token': sessionToken,
      if (afterId != null) 'after_id': '$afterId',
    };
    final uri = _u('/api/children/$childId/around-audio/latest/').replace(
      queryParameters: params,
    );
    final r = await http.get(uri, headers: _headers(json: false));
    if (r.statusCode == 204 || r.body.isEmpty) return null;
    return _decode(r) as Map<String, dynamic>;
  }

  // === WebRTC Monitoring ===
  Future<Map<String, dynamic>> activateMonitoring(int childId) async {
    return await _post('/api/monitor/activate/', {
      'child_id': childId,
    });
  }

  Future<void> deactivateMonitoring({
    int? childId,
    String? sessionToken,
  }) async {
    await _post('/api/monitor/deactivate/', {
      if (childId != null) 'child_id': childId,
      if (sessionToken != null) 'session_token': sessionToken,
    });
  }

  Future<void> sendSignalingMessage({
    required String sessionToken,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    await _post('/api/monitor/signal/send/', {
      'session_token': sessionToken,
      'type': type,
      'payload': payload,
    });
  }

  Future<Map<String, dynamic>> pollSignalingMessages({
    required String sessionToken,
    int? afterId,
  }) async {
    final params = <String, String>{
      'session_token': sessionToken,
      if (afterId != null) 'after_id': '$afterId',
    };
    final uri = _u('/api/monitor/signal/poll/').replace(
      queryParameters: params,
    );
    final r = await http.get(uri, headers: _headers(json: false));
    return _decode(r) as Map<String, dynamic>;
  }

  // === Alerts ===
  Future<List<dynamic>> getAlerts() async {
    return (await _get('/api/alerts/')) as List<dynamic>;
  }

  Future<void> markAlertRead(int alertId) async {
    await _post('/api/alerts/$alertId/read/', {});
  }

  Future<void> markAllAlertsRead() async {
    await _post('/api/alerts/read-all/', {});
  }

  // === Child Notifications (polling fallback) ===
  Future<List<dynamic>> childNotifications() async {
    return (await _get('/api/chat/notifications/')) as List<dynamic>;
  }

  // === Chat ===
  Future<List<dynamic>> getMessages(int childId) async {
    return (await _get('/api/chat/$childId/messages/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> markMessagesRead(
    int childId, {
    List<int>? messageIds,
  }) async {
    return await _post('/api/chat/$childId/messages/read/', {
      if (messageIds != null && messageIds.isNotEmpty)
        'message_ids': messageIds,
    });
  }

  Future<Map<String, dynamic>> sendMessage(int childId, String text) async {
    return await _post('/api/chat/$childId/messages/', {'text': text});
  }

  Future<Map<String, dynamic>> sendMessageWithFile(
    int childId, {
    String text = '',
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _u('/api/chat/$childId/messages/'),
    );
    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }
    if (text.isNotEmpty) {
      request.fields['text'] = text;
    }
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final client = http.Client();
    final uploadDone = Completer<void>();
    try {
      final finalizedStream = request.finalize();
      final totalBytes = request.contentLength;
      final streamedRequest = http.StreamedRequest(request.method, request.url);
      streamedRequest.headers.addAll(request.headers);
      streamedRequest.contentLength = totalBytes;
      var sentBytes = 0;

      finalizedStream.listen(
        (chunk) {
          streamedRequest.sink.add(chunk);
          if (totalBytes > 0) {
            sentBytes += chunk.length;
            onProgress?.call((sentBytes / totalBytes).clamp(0.0, 1.0));
          }
        },
        onDone: () {
          streamedRequest.sink.close();
          if (!uploadDone.isCompleted) uploadDone.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          streamedRequest.sink.addError(error, stackTrace);
          streamedRequest.sink.close();
          if (!uploadDone.isCompleted) {
            uploadDone.completeError(error, stackTrace);
          }
        },
        cancelOnError: true,
      );

      final streamed = await client.send(streamedRequest);
      await uploadDone.future;
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw ApiException(streamed.statusCode, body);
      }
      onProgress?.call(1);
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  // === Tasks ===
  Future<List<dynamic>> getTasks(int childId) async {
    return (await _get('/api/chat/$childId/tasks/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createTask(
    int childId, {
    required String title,
    String description = '',
    int rewardStars = 0,
  }) async {
    return await _post('/api/chat/$childId/tasks/', {
      'title': title,
      'description': description,
      'reward_stars': rewardStars,
    });
  }

  Future<Map<String, dynamic>> completeTask(int childId, int taskId) async {
    final r = await http.patch(
      _u('/api/chat/$childId/tasks/$taskId/complete/'),
      headers: _headers(),
    );
    return _decode(r) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> approveTask(int childId, int taskId) async {
    final r = await http.patch(
      _u('/api/chat/$childId/tasks/$taskId/approve/'),
      headers: _headers(),
    );
    return _decode(r) as Map<String, dynamic>;
  }

  Future<void> deleteTask(int childId, int taskId) async {
    await _delete('/api/chat/$childId/tasks/$taskId/');
  }

  // === Stars ===
  Future<Map<String, dynamic>> getStars(int childId) async {
    return (await _get('/api/chat/$childId/stars/')) as Map<String, dynamic>;
  }

  // === Rewards ===
  Future<List<dynamic>> getRewards(int childId) async {
    return (await _get('/api/chat/$childId/rewards/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createReward(
    int childId, {
    required String title,
    required int requiredStars,
  }) async {
    return await _post('/api/chat/$childId/rewards/', {
      'title': title,
      'required_stars': requiredStars,
    });
  }

  Future<Map<String, dynamic>> claimReward(int childId, int rewardId) async {
    final r = await http.patch(
      _u('/api/chat/$childId/rewards/$rewardId/claim/'),
      headers: _headers(),
    );
    return _decode(r) as Map<String, dynamic>;
  }

  Future<void> deleteReward(int childId, int rewardId) async {
    await _delete('/api/chat/$childId/rewards/$rewardId/');
  }
}
