# Architecture

Technical architecture and design patterns used in the Superthread Flutter app.

## Overall Architecture

The app follows Clean Architecture principles with clear separation of concerns:

- **Presentation Layer** (Widgets, Screens, BLoCs)
- **Domain Layer** (Use Cases, Business Logic)
- **Data Layer** (Repositories, API, Local Storage)

## Project Structure

```
lib/
├── core/                    # Core utilities
│   ├── constants/          # App constants
│   ├── router/             # Navigation/router
│   ├── services/           # DI (service_locator)
│   ├── themes/             # App themes
│   ├── utils/              # Utility functions
│   └── errors/             # Error handling
│
├── data/                   # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Repository implementations
│   └── datasources/        # API and local data sources
│
├── presentation/           # Presentation layer
│   ├── bloc/              # BLoC state management
│   ├── pages/             # Screen widgets
│   └── widgets/           # Reusable widgets
│
└── main.dart              # App entry point
```

## Design Patterns

### BLoC Pattern

Used for state management throughout the app.

```dart
class CardBloc extends Bloc<CardEvent, CardState> {
  final ApiService _apiService;
  
  CardBloc(this._apiService) : super(CardInitial()) {
    on<LoadCards>(_onLoadCards);
  }
  
  Future<void> _onLoadCards(LoadCards event, Emitter<CardState> emit) async {
    emit(CardLoading());
    try {
      final cards = await _apiService.getCards();
      emit(CardsLoaded(cards));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }
}
```

### Repository Pattern

```dart
abstract class CardRepository {
  Future<List<Card>> getCards();
}

class CardRepositoryImpl implements CardRepository {
  final ApiService _apiService;
  final LocalStorage _localStorage;
  
  @override
  Future<List<Card>> getCards() async {
    final cached = await _localStorage.getCards();
    if (cached != null) return cached;
    
    final cards = await _apiService.getCards();
    await _localStorage.saveCards(cards);
    return cards;
  }
}
```

### Dependency Injection

Uses get_it service locator:

```dart
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerFactory<CardBloc>(() => CardBloc(sl<ApiService>()));
}
```

## State Management

### State Classes

```dart
abstract class CardState {}

class CardInitial extends CardState {}
class CardLoading extends CardState {}
class CardsLoaded extends CardState {
  final List<Card> cards;
  CardsLoaded(this.cards);
}
class CardError extends CardState {
  final String message;
  CardError(this.message);
}
```

## API Integration

### Retrofit Setup

```dart
@RestApi(baseUrl: "https://api.superthread.com/v1")
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;
  
  @GET("/{teamId}/cards")
  Future<CardsResponse> getCards(@Path("teamId") String teamId);
}
```

## WebSocket

```dart
class WebSocketService {
  WebSocketChannel? _channel;
  
  Future<void> connect(String url) async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.stream.listen((data) => _handleMessage(data));
  }
  
  Stream<RealtimeEvent> getEventsForCard(String cardId) {
    return _eventController.stream.where((event) => event.cardId == cardId);
  }
}
```

## Security

### Token Management

```dart
class AuthInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

---

*See [Data Models](Data-Models) for model details.*
