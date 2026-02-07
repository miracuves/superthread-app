import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../api/api_models.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final Map<String, StreamSubscription> _subscriptions = {};
  final StreamController<RealtimeEvent> _eventController = StreamController<RealtimeEvent>.broadcast();
  final Map<String, UserPresence> _userPresence = {};

  Stream<RealtimeEvent> get events => _eventController.stream;

  Future<void> connect(String url, {String? token}) async {
    // Avoid duplicate connections
    if (_channel != null) return;
    try {
      Uri wsUrl = Uri.parse(url);

      // Ensure token is included (headers on IO, query parameter on web)
      if (token != null && token.isNotEmpty) {
        if (kIsWeb) {
          wsUrl = wsUrl.replace(
            queryParameters: {
              ...wsUrl.queryParameters,
              'token': token,
            },
          );
        }
      }

      if (kIsWeb) {
        // Headers are not supported on web; rely on token in query
        _channel = WebSocketChannel.connect(wsUrl);
      } else {
        final headers = token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : null;
        _channel = IOWebSocketChannel.connect(
          wsUrl,
          headers: headers,
        );
      }
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            final event = RealtimeEvent.fromJson(data);
            _eventController.add(event);
            
            // Handle specific event types
            _handleRealtimeEvent(event);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _channel = null;
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void subscribeToTeam(String teamId) {
    sendMessage({
      'type': 'subscribe',
      'teamId': teamId,
    });
  }

  void subscribeToBoard(String boardId) {
    sendMessage({
      'type': 'subscribe',
      'boardId': boardId,
    });
  }

  void subscribeToCard(String cardId) {
    sendMessage({
      'type': 'subscribe',
      'cardId': cardId,
    });
  }

  void unsubscribeFromCard(String cardId) {
    sendMessage({
      'type': 'unsubscribe',
      'cardId': cardId,
    });
  }

  void unsubscribeFromTeam(String teamId) {
    sendMessage({
      'type': 'unsubscribe',
      'teamId': teamId,
    });
  }

  void sendUserPresence(String teamId, String? cardId, String? boardId) {
    sendMessage({
      'type': 'presence',
      'teamId': teamId,
      'cardId': cardId,
      'boardId': boardId,
      'status': 'online',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    switch (event.type) {
      case 'card_updated':
      case 'card_created':
      case 'card_deleted':
      case 'card_moved':
        // Handle card-related events
        _handleCardEvent(event);
        break;
      case 'user_joined':
      case 'user_left':
      case 'user_presence':
        // Handle presence events
        _handlePresenceEvent(event);
        break;
      case 'comment_added':
      case 'comment_updated':
      case 'comment_deleted':
        // Handle comment events
        _handleCommentEvent(event);
        break;
      case 'sprint_started':
      case 'sprint_completed':
      case 'sprint_updated':
        // Handle sprint events
        _handleSprintEvent(event);
        break;
      default:
        print('Unhandled event type: ${event.type}');
    }
  }

  void _handleCardEvent(RealtimeEvent event) {
    // This will be handled by UI components listening to the events stream
    print('Card event: ${event.type} - ${event.data}');
  }

  void _handlePresenceEvent(RealtimeEvent event) {
    if (event.data['userId'] != null && event.data['status'] != null) {
      final presence = UserPresence(
        userId: event.data['userId'],
        cardId: event.data['cardId'],
        boardId: event.data['boardId'],
        status: event.data['status'],
        lastSeen: event.timestamp,
      );
      
      _userPresence[event.data['userId']] = presence;
    }
  }

  void _handleCommentEvent(RealtimeEvent event) {
    print('Comment event: ${event.type} - ${event.data}');
  }

  void _handleSprintEvent(RealtimeEvent event) {
    print('Sprint event: ${event.type} - ${event.data}');
  }

  Map<String, UserPresence> get userPresence => Map.unmodifiable(_userPresence);

  Stream<RealtimeEvent> getEventsForType(String eventType) {
    return _eventController.stream.where((event) => event.type == eventType);
  }

  Stream<RealtimeEvent> getEventsForTeam(String teamId) {
    return _eventController.stream.where((event) => event.teamId == teamId);
  }

  Stream<RealtimeEvent> getEventsForCard(String cardId) {
    return _eventController.stream.where((event) => 
        event.data['cardId'] == cardId || 
        event.data.containsKey('cardIds') && 
        (event.data['cardIds'] as List).contains(cardId));
  }

  bool get isConnected => _channel != null;

  void sendTypingIndicator(String teamId, String cardId, bool isTyping) {
    sendMessage({
      'type': 'typing',
      'teamId': teamId,
      'cardId': cardId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void sendCursorPosition(String teamId, String cardId, int cursorPosition) {
    sendMessage({
      'type': 'cursor_position',
      'teamId': teamId,
      'cardId': cardId,
      'cursorPosition': cursorPosition,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}