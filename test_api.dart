// Test script to verify API connectivity and data loading
// Run this to check if the API is returning data correctly

import 'package:dio/dio.dart';

void main() async {
  // Replace with your actual PAT token and team ID
  const String patToken = 'YOUR_PAT_TOKEN_HERE';
  const String teamId = 'YOUR_TEAM_ID_HERE';
  const String baseUrl = 'https://api.superthread.com/v1';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Authorization': 'Bearer $patToken',
      'Content-Type': 'application/json',
    },
  ));

  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  print('Testing Superthread API...\n');

  // Test 1: Get current user
  try {
    print('1. Testing GET /users/me');
    final userResponse = await dio.get('/users/me');
    print('✅ User API works!');
    print('User: ${userResponse.data['user']['name']}');
    print('Teams: ${userResponse.data['user']['teams']}');
    print('');
  } catch (e) {
    print('❌ User API failed: $e\n');
  }

  // Test 2: Get boards
  try {
    print('2. Testing GET /$teamId/boards');
    final boardsResponse = await dio.get('/$teamId/boards', queryParameters: {
      'archived': 'false',
    });
    print('✅ Boards API works!');
    print('Boards count: ${boardsResponse.data['boards']?.length ?? 0}');
    if (boardsResponse.data['boards'] != null && boardsResponse.data['boards'].isNotEmpty) {
      print('First board: ${boardsResponse.data['boards'][0]['name']}');
    }
    print('');
  } catch (e) {
    print('❌ Boards API failed: $e\n');
  }

  // Test 3: Get cards
  try {
    print('3. Testing GET /$teamId/cards');
    final cardsResponse = await dio.get('/$teamId/cards', queryParameters: {
      'archived': 'true', // API requires archived parameter when no boardId/listId
    });
    print('✅ Cards API works!');
    print('Cards count: ${cardsResponse.data['cards']?.length ?? 0}');
    if (cardsResponse.data['cards'] != null && cardsResponse.data['cards'].isNotEmpty) {
      print('First card: ${cardsResponse.data['cards'][0]['title']}');
    }
    print('');
  } catch (e) {
    print('❌ Cards API failed: $e\n');
  }

  // Test 4: Get notes
  try {
    print('4. Testing GET /$teamId/notes');
    final notesResponse = await dio.get('/$teamId/notes');
    print('✅ Notes API works!');
    print('Notes count: ${notesResponse.data['notes']?.length ?? 0}');
    if (notesResponse.data['notes'] != null && notesResponse.data['notes'].isNotEmpty) {
      print('First note: ${notesResponse.data['notes'][0]['title']}');
    }
    print('');
  } catch (e) {
    print('❌ Notes API failed: $e\n');
  }

  // Test 5: Get epics
  try {
    print('5. Testing GET /$teamId/epics');
    final epicsResponse = await dio.get('/$teamId/epics');
    print('✅ Epics API works!');
    print('Epics count: ${epicsResponse.data['epics']?.length ?? 0}');
    if (epicsResponse.data['epics'] != null && epicsResponse.data['epics'].isNotEmpty) {
      print('First epic: ${epicsResponse.data['epics'][0]['title']}');
    }
    print('');
  } catch (e) {
    print('❌ Epics API failed: $e\n');
  }

  print('\nTest complete!');
  print('\nIf all tests passed but the app shows no data, the issue is likely:');
  print('1. Authentication not persisting correctly');
  print('2. BLoC not emitting states correctly');
  print('3. UI not rebuilding when state changes');
}
