// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:superthread_app/core/network/dio_client.dart';
import 'package:superthread_app/core/services/api/api_service.dart';
import 'package:superthread_app/core/services/connectivity/connectivity_service.dart';
import 'package:superthread_app/core/services/notifications/superthread_notification_service.dart';
import 'package:superthread_app/core/services/service_locator.dart';
import 'package:superthread_app/core/services/storage/storage_service.dart';
import 'package:superthread_app/main.dart';

class FakeStorageService extends StorageService {
  final Map<String, String?> _secure = {};
  final Map<String, Object?> _prefs = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> saveAccessToken(String token) async => _secure['access_token'] = token;

  @override
  Future<String?> getAccessToken() async => _secure['access_token'];

  @override
  Future<void> removeAccessToken() async => _secure.remove('access_token');

  @override
  Future<void> saveTeamId(String teamId) async => _secure['team_id'] = teamId;

  @override
  Future<String?> getTeamId() async => _secure['team_id'];

  @override
  Future<void> removeTeamId() async => _secure.remove('team_id');

  @override
  Future<void> saveUserId(String userId) async => _secure['user_id'] = userId;

  @override
  Future<String?> getUserId() async => _secure['user_id'];

  @override
  Future<void> removeUserId() async => _secure.remove('user_id');

  @override
  Future<bool> isFirstLaunch() async => (_prefs['is_first_launch'] as bool?) ?? true;

  @override
  Future<void> setFirstLaunch(bool isFirst) async => _prefs['is_first_launch'] = isFirst;

  @override
  Future<String> getThemeMode() async => (_prefs['theme_mode'] as String?) ?? 'system';

  @override
  Future<void> setThemeMode(String themeMode) async => _prefs['theme_mode'] = themeMode;

  @override
  Future<String> getLanguageCode() async => (_prefs['language_code'] as String?) ?? 'en';

  @override
  Future<void> setLanguageCode(String languageCode) async => _prefs['language_code'] = languageCode;

  @override
  Future<List<String>> getSearchHistory() async => List<String>.from((_prefs['search_history'] as List<String>?) ?? []);

  @override
  Future<void> saveSearchHistory(List<String> history) async => _prefs['search_history'] = List<String>.from(history);

  @override
  Future<void> clearSearchHistory() async => _prefs.remove('search_history');

  @override
  Future<bool> getNotificationsEnabled() async => (_prefs['notifications_enabled'] as bool?) ?? true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async => _prefs['notifications_enabled'] = enabled;

  @override
  Future<bool> getBiometricEnabled() async => (_prefs['biometric_enabled'] as bool?) ?? false;

  @override
  Future<void> setBiometricEnabled(bool enabled) async => _prefs['biometric_enabled'] = enabled;

  @override
  Future<bool> getAutoSyncEnabled() async => (_prefs['auto_sync_enabled'] as bool?) ?? true;

  @override
  Future<void> setAutoSyncEnabled(bool enabled) async => _prefs['auto_sync_enabled'] = enabled;

  @override
  Future<String> getDefaultView() async => (_prefs['default_view'] as String?) ?? 'grid';

  @override
  Future<void> setDefaultView(String view) async => _prefs['default_view'] = view;

  @override
  Future<void> clearNotifications() async => _secure['notifications'] = '[]';

  @override
  Future<String> getNotificationPreferences() async => _secure['notification_preferences'] ?? '{}';

  @override
  Future<void> saveNotificationPreferences(String preferences) async => _secure['notification_preferences'] = preferences;

  @override
  Future<void> saveNotification(Map<String, dynamic> notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    _secure['notifications'] = notifications.toString();
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final stored = _secure['notifications'];
    if (stored == null || stored.isEmpty) return [];
    // Stored as string via toString; not parsed for tests.
    return [];
  }

  @override
  Future<String?> secureRead(String key) async => _secure[key];

  @override
  Future<void> secureWrite(String key, String value) async => _secure[key] = value;

  @override
  Future<void> clearAll() async {
    _secure.clear();
    _prefs.clear();
  }
}

class FakeConnectivityService implements ConnectivityService {
  bool _online = true;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  ConnectivityResult get currentResult => _online ? ConnectivityResult.wifi : ConnectivityResult.none;

  @override
  bool get isOnline => _online;

  @override
  bool get isConnectionSlow => false;

  @override
  Stream<bool> get connectionStream => _controller.stream;

  @override
  Future<bool> checkConnectivity() async => _online;

  @override
  String get connectionStatusText => _online ? 'Connected' : 'No Connection';

  @override
  Future<void> init() async {}

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Reset and register lightweight test dependencies
    await sl.reset();
    final storage = FakeStorageService();
    await storage.init();
    sl.registerSingleton<StorageService>(storage);

    final dioClient = DioClient(storage);
    sl.registerSingleton<DioClient>(dioClient);
    sl.registerSingleton<ApiService>(ApiService(dioClient));
    sl.registerSingleton<ConnectivityService>(FakeConnectivityService());
    sl.registerSingleton<SuperthreadNotificationService>(SuperthreadNotificationService());
  });

  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SuperthreadApp());

    // Allow splash timers/navigation to complete
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
