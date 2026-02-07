import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/pages/auth/splash_screen.dart';
import '../../presentation/pages/auth/login_screen.dart';
import '../../presentation/pages/dashboard/dashboard_screen.dart';
import '../../presentation/pages/dashboard/home_screen.dart';
import '../../presentation/pages/dashboard/projects_screen.dart';
import '../../presentation/pages/dashboard/cards_screen.dart';
import '../../presentation/pages/dashboard/notes_screen.dart';
import '../../presentation/pages/dashboard/search_screen.dart';
import '../../presentation/pages/dashboard/profile_screen.dart';
import '../../presentation/pages/note_editor_screen.dart';
import '../../presentation/pages/kanban_board_screen.dart';
import '../../presentation/pages/card_detail_screen.dart';
import '../../presentation/pages/notifications/notification_history_screen.dart';
import '../../presentation/pages/notifications/notifications_settings_screen.dart';
import '../../presentation/pages/dashboard/pages_screen.dart';
import '../../presentation/pages/page_editor_screen.dart';
import '../../presentation/bloc/pages/page_bloc.dart';

/// App Router Configuration
class AppRouter {
  final AuthBloc authBloc;
  bool get initialized => _router != null;
  GoRouter? _router;

  AppRouter({required this.authBloc}) {
    _router = GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.uri.toString();

        // If not authenticated and not on auth pages, redirect to login
        if (authState is! Authenticated &&
            !location.startsWith('/splash') &&
            !location.startsWith('/login')) {
          return '/login';
        }

        // If authenticated and on auth pages, redirect to dashboard
        if (authState is Authenticated &&
            (location.startsWith('/splash') ||
             location.startsWith('/login'))) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Standalone routes (outside shell for modals/overlays)
        GoRoute(
          path: '/notifications/history',
          name: 'notification-history',
          builder: (context, state) => const NotificationHistoryScreen(),
        ),
        GoRoute(
          path: '/notifications/settings',
          name: 'notification-settings',
          builder: (context, state) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: '/kanban/:boardId',
          name: 'kanban-board',
          builder: (context, state) {
            final boardId = state.pathParameters['boardId']!;
            final boardName = state.uri.queryParameters['name'] ?? 'Board';
            return KanbanBoardScreen(
              boardId: boardId,
              boardName: boardName,
            );
          },
        ),
        GoRoute(
          path: '/card/:cardId',
          name: 'card-detail',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return CardDetailScreen(cardId: cardId);
          },
        ),

        // Dashboard Routes (Shell Route)
        ShellRoute(
          builder: (context, state, child) {
            return DashboardScreen(
              currentIndex: _getTabIndexFromPath(state.uri.toString()),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/projects',
              name: 'projects',
              builder: (context, state) => const ProjectsScreen(),
            ),
            GoRoute(
              path: '/cards',
              name: 'cards',
              builder: (context, state) => const CardsScreen(),
            ),
            GoRoute(
              path: '/notes',
              name: 'notes',
              builder: (context, state) => const NotesScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'note-create',
                  builder: (context, state) => const NoteEditorScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'note-edit',
                  builder: (context, state) {
                    final noteId = state.pathParameters['id']!;
                    return NoteEditorScreen(noteId: noteId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/pages',
              name: 'pages',
              builder: (context, state) => const PagesScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'page-create',
                  builder: (context, state) => BlocProvider(
                    create: (context) => PageBloc(
                      context.read(),
                      context.read(),
                    ),
                    child: const PageEditorScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  name: 'page-edit',
                  builder: (context, state) {
                    final pageId = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (context) => PageBloc(
                        context.read(),
                        context.read(),
                      ),
                      child: PageEditorScreen(pageId: pageId),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],

      // Error handling
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not find a page for path: ${state.uri.toString()}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get tab index from path
  int _getTabIndexFromPath(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/projects')) return 1;
    if (path.startsWith('/cards')) return 2;
    if (path.startsWith('/notes')) return 3;
     if (path.startsWith('/search')) return 4;
     if (path.startsWith('/profile')) return 5;
    return 0;
  }

  GoRouter get router => _router!;
}

/// Navigation Helper Class
class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  // Dashboard Navigation
  static void goHome() => context?.go('/dashboard');
  static void goProjects() => context?.go('/projects');
  static void goCards() => context?.go('/cards');
  static void goNotes() => context?.go('/notes');
  static void goSearch() => context?.go('/search');

  // Auth Navigation
  static void goLogin() => context?.go('/login');
  static void goSplash() => context?.go('/splash');

  // Detail Navigation
  static void goProjectDetail(String projectId) =>
      context?.go('/projects/$projectId');

  static void goBoardDetail(String boardId) =>
      context?.go('/projects/boards/$boardId');

  static void goCardDetail(String cardId) =>
      context?.go('/cards/$cardId');

  static void goNoteDetail(String noteId) =>
      context?.go('/notes/$noteId');

  // Creation Navigation
  static void goCreateProject() => context?.go('/projects/create');
  static void goCreateBoard({String? projectId}) {
    if (projectId != null) {
      context?.go('/projects/$projectId/boards/create');
    } else {
      context?.go('/boards/create');
    }
  }

  static void goCreateCard({String? boardId}) {
    if (boardId != null) {
      context?.go('/boards/$boardId/cards/create');
    } else {
      context?.go('/cards/create');
    }
  }

  static void goCreateNote() => context?.go('/notes/create');

  // Search Navigation
  static void goSearchResults(String query, {String? type}) {
    final params = <String, String>{'q': query};
    if (type != null) params['type'] = type;
    context?.go('/search/results', extra: params);
  }

  // Utility Methods
  static String? currentRoute() {
    final RouteData? route = RouteData.of(context);
    return route?.location;
  }

  static void back() => context?.pop();

  static void replaceWith(String route) => context?.go(route);

  // Build navigation options with custom transitions
  static PageRouteBuilder<T> customRoute<T>({
    required Widget child,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

/// Route Data Helper
class RouteData {
  static RouteData? of(BuildContext? context) {
    return null; // Will be implemented based on actual routing needs
  }

  final String location;
  final Map<String, dynamic> parameters;

  RouteData({
    required this.location,
    this.parameters = const {},
  });
}

/// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}