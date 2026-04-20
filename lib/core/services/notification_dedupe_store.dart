import 'package:shared_preferences/shared_preferences.dart';

class NotificationDedupeStore {
  NotificationDedupeStore._();

  static const childShownIdsKey = 'child_notification_shown_ids';
  static const parentAlertShownIdsKey = 'notification_shown_alert_ids';
  static const _maxStoredIds = 200;

  static Future<Set<String>> loadChildShownIds() async {
    return _load(childShownIdsKey);
  }

  static Future<void> saveChildShownIds(Set<String> ids) async {
    await _save(childShownIdsKey, ids);
  }

  static Future<void> recordChildMessage(int messageId) async {
    await _record(childShownIdsKey, 'msg_$messageId');
  }

  static Future<void> recordChildTask(int taskId) async {
    await _record(childShownIdsKey, 'task_$taskId');
  }

  static Future<Set<String>> loadParentAlertShownIds() async {
    return _load(parentAlertShownIdsKey);
  }

  static Future<void> saveParentAlertShownIds(Set<String> ids) async {
    await _save(parentAlertShownIdsKey, ids);
  }

  static Future<void> recordParentAlert(int alertId) async {
    await _record(parentAlertShownIdsKey, '$alertId');
  }

  static Future<Set<String>> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(key) ?? const <String>[]).toSet();
  }

  static Future<void> _record(String key, String value) async {
    final ids = await _load(key);
    ids.add(value);
    await _save(key, ids);
  }

  static Future<void> _save(String key, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final list = ids.toList();
    final trimmed = list.length > _maxStoredIds
        ? list.sublist(list.length - _maxStoredIds)
        : list;
    await prefs.setStringList(key, trimmed);
  }
}
