import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'core/themes/app_theme.dart';
import 'core/services/service_locator.dart';
import 'core/services/storage/storage_service.dart';
import 'core/services/api/api_service.dart';
import 'core/services/notifications/superthread_notification_service.dart';
import 'core/router/app_router.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/boards/board_bloc.dart';
import 'presentation/bloc/cards/card_bloc.dart';
import 'presentation/bloc/notes/note_bloc.dart';
import 'presentation/bloc/pages/page_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';
import 'presentation/bloc/epics/epic_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const SuperthreadApp());
}

class SuperthreadApp extends StatefulWidget {
  const SuperthreadApp({super.key});

  @override
  State<SuperthreadApp> createState() => _SuperthreadAppState();
}

class _SuperthreadAppState extends State<SuperthreadApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize router after AuthBloc is created
    final authBloc = AuthBloc(sl<ApiService>(), sl<StorageService>())
      ..add(CheckAuthenticationStatus());

    _appRouter = AppRouter(authBloc: authBloc);

    // Listen to authentication state for notification service
    authBloc.stream.listen((state) {
      final notificationService = sl<SuperthreadNotificationService>();
      if (state is Authenticated) {
        // Start notification polling when user is authenticated
        notificationService.startPolling(state.teamId);
      } else {
        // Stop notification polling when user is not authenticated
        notificationService.stopPolling();
      }
    });

    // Rebuild with router
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If router is not initialized yet, show loading
    if (!_appRouter.initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appRouter.authBloc),
        BlocProvider(
          create: (context) => ThemeBloc(sl<StorageService>()),
        ),
        BlocProvider(
          create: (context) => BoardBloc(
            sl<ApiService>(),
            sl<StorageService>(),
          ),
        ),
        BlocProvider(
          create: (context) => CardBloc(
            sl<ApiService>(),
            sl<StorageService>(),
          ),
        ),
        BlocProvider(
          create: (context) => NoteBloc(
            sl<ApiService>(),
            sl<StorageService>(),
          ),
        ),
        BlocProvider(
          create: (context) => PageBloc(
            sl<ApiService>(),
            sl<StorageService>(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchBloc(
            apiService: sl<ApiService>(),
          ),
        ),
        BlocProvider(
          create: (context) => EpicBloc(
            sl<ApiService>(),
            sl<StorageService>(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          ThemeMode mode = ThemeMode.system;
          if (themeState is AppThemeState) {
            mode = themeState.themeMode;
          }

          return MaterialApp.router(
            title: 'Superthread',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,

            // Localization
            locale: const Locale('en'),
            supportedLocales: const [
              Locale('en'),
            ],

            // Router Configuration
            routerConfig: _appRouter.router,

            // Builder for additional configurations
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scale factor doesn't exceed certain limits
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
