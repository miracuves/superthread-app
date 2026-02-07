import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _teamIdKey = 'team_id';
  static const String _userIdKey = 'user_id';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';
  static const String _searchHistoryKey = 'search_history';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoSyncEnabledKey = 'auto_sync_enabled';
  static const String _defaultViewKey = 'default_view';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage for sensitive data
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> removeAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  Future<void> saveTeamId(String teamId) async {
    await _secureStorage.write(key: _teamIdKey, value: teamId);
  }

  Future<String?> getTeamId() async {
    return await _secureStorage.read(key: _teamIdKey);
  }

  Future<void> removeTeamId() async {
    await _secureStorage.delete(key: _teamIdKey);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<void> removeUserId() async {
    await _secureStorage.delete(key: _userIdKey);
  }

  // Regular SharedPreferences for non-sensitive data
  Future<bool> isFirstLaunch() async {
    return _prefs?.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool(_isFirstLaunchKey, isFirst);
  }

  Future<String> getThemeMode() async {
    return _prefs?.getString(_themeModeKey) ?? 'system';
  }

  Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_themeModeKey, themeMode);
  }

  Future<String> getLanguageCode() async {
    return _prefs?.getString(_languageCodeKey) ?? 'en';
  }

  Future<void> setLanguageCode(String languageCode) async {
    await _prefs?.setString(_languageCodeKey, languageCode);
  }

  // Search History
  Future<List<String>> getSearchHistory() async {
    final historyJson = _prefs?.getStringList(_searchHistoryKey) ?? [];
    return historyJson;
  }

  Future<void> saveSearchHistory(List<String> history) async {
    await _prefs?.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs?.remove(_searchHistoryKey);
  }

  // User Preferences
  Future<bool> getNotificationsEnabled() async {
    return _prefs?.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
  }

  Future<bool> getBiometricEnabled() async {
    return _prefs?.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs?.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> getAutoSyncEnabled() async {
    return _prefs?.getBool(_autoSyncEnabledKey) ?? true;
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _prefs?.setBool(_autoSyncEnabledKey, enabled);
  }

  Future<String> getDefaultView() async {
    return _prefs?.getString(_defaultViewKey) ?? 'grid';
  }

  Future<void> setDefaultView(String view) async {
    await _prefs?.setString(_defaultViewKey, view);
  }

  Future<void> clearNotifications() async {
    await secureWrite('notifications', jsonEncode([]));
  }

  // Notification storage methods
  Future<String> getNotificationPreferences() async {
    return await secureRead('notification_preferences') ?? '{}';
  }

  Future<void> saveNotificationPreferences(String preferences) async {
    await secureWrite('notification_preferences', preferences);
  }

  Future<void> saveNotification(Map<String, dynamic> notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);

    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await secureWrite('notifications', jsonEncode(notifications));
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final notificationsJson = await secureRead('notifications') ?? '[]';
      final List<dynamic> notificationsList = jsonDecode(notificationsJson);
      return notificationsList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      return [];
    }
  }

  // Helper methods for secure storage
  Future<String?> secureRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Failed to read secure key $key: $e');
      return null;
    }
  }

  Future<void> secureWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Failed to write secure key $key: $e');
    }
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}