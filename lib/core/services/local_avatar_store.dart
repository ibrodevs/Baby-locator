import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAvatarStore {
  LocalAvatarStore._();
  static final LocalAvatarStore instance = LocalAvatarStore._();

  static const _userPrefix = 'local_avatar_user_';
  static const _childPrefix = 'local_avatar_child_';

  final Map<String, String> _cache = {};
  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_userPrefix) || key.startsWith(_childPrefix)) {
        final v = prefs.getString(key);
        if (v != null && File(v).existsSync()) {
          _cache[key] = v;
        }
      }
    }
    _loaded = true;
  }

  String? userAvatar(int? id) {
    if (id == null) return null;
    return _cache['$_userPrefix$id'];
  }

  String? childAvatar(int? id) {
    if (id == null) return null;
    return _cache['$_childPrefix$id'];
  }

  Future<String> saveUserAvatar(int id, File source) =>
      _save('$_userPrefix$id', source);

  Future<String> saveChildAvatar(int id, File source) =>
      _save('$_childPrefix$id', source);

  Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final old = _cache.remove(key);
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    await prefs.remove(key);
    revision.value++;
  }

  Future<String> _save(String key, File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/avatars');
    if (!avatarsDir.existsSync()) {
      avatarsDir.createSync(recursive: true);
    }
    final ext = _extOf(source.path);
    final filename =
        '${key}_${DateTime.now().microsecondsSinceEpoch}$ext';
    final dest = File('${avatarsDir.path}/$filename');
    await source.copy(dest.path);

    final prefs = await SharedPreferences.getInstance();
    final old = _cache[key];
    if (old != null && old != dest.path) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    _cache[key] = dest.path;
    await prefs.setString(key, dest.path);
    revision.value++;
    return dest.path;
  }

  String _extOf(String path) {
    final i = path.lastIndexOf('.');
    if (i < 0 || i >= path.length - 1) return '.jpg';
    return path.substring(i);
  }
}

ImageProvider? avatarImageProvider(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }
  if (kIsWeb) return null;
  final f = File(value);
  if (!f.existsSync()) return null;
  return FileImage(f);
}

String? resolveUserAvatar(int? userId, String? remoteUrl) {
  final local = LocalAvatarStore.instance.userAvatar(userId);
  return local ?? remoteUrl;
}

String? resolveChildAvatar(int? childId, String? remoteUrl) {
  final local = LocalAvatarStore.instance.childAvatar(childId);
  return local ?? remoteUrl;
}
