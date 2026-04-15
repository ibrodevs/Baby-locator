import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the Django backend.
/// - iOS simulator & macOS/desktop: localhost works.
/// - Android emulator: 10.0.2.2 maps to host.
/// Override with --dart-define=API_BASE=http://192.168.x.x:8000
class ApiConfig {
  static const String _defineBase =
      String.fromEnvironment('API_BASE', defaultValue: '');

  static String get baseUrl {
    if (_defineBase.isNotEmpty) return _defineBase;
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
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
  String? get token => _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String? t) async {
    _token = t;
    final prefs = await SharedPreferences.getInstance();
    if (t == null) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', t);
    }
  }

  Map<String, String> _headers({bool json = true}) {
    return {
      if (json) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Token $_token',
    };
  }

  Uri _u(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final r = await http.post(_u(path),
        headers: _headers(), body: jsonEncode(body));
    return _decode(r);
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
    await _saveToken(data['token'] as String);
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
    await _saveToken(data['token'] as String);
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    return (await _get('/api/auth/me/')) as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _saveToken(null);
  }

  // === Children ===
  Future<List<dynamic>> listChildren() async {
    return (await _get('/api/auth/children/')) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createChild({
    required String username,
    required String password,
    String? displayName,
  }) async {
    return await _post('/api/auth/children/', {
      'username': username,
      'password': password,
      if (displayName != null) 'display_name': displayName,
    });
  }

  // === Location ===
  Future<Map<String, dynamic>> shareLocation({
    required double lat,
    required double lng,
    String? address,
    int? battery,
    bool? active,
  }) async {
    return await _post('/api/locations/', {
      'lat': lat,
      'lng': lng,
      if (address != null) 'address': address,
      if (battery != null) 'battery': battery,
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
}
