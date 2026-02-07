import 'package:get_it/get_it.dart';
import 'services/api/api_service.dart';
import 'network/dio_client.dart';
import 'services/storage/storage_service.dart';
import 'services/notifications/notification_service.dart';
import 'services/notifications/superthread_notification_service.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/boards/board_bloc.dart';
import '../presentation/bloc/cards/card_bloc.dart';
import '../presentation/bloc/notes/note_bloc.dart';
import '../presentation/bloc/pages/page_bloc.dart';
import '../presentation/bloc/search/search_bloc.dart';
import '../presentation/bloc/sprint/sprint_bloc.dart';
import '../presentation/bloc/theme/theme_bloc.dart';

final GetIt getService = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core services
  getService.registerLazySingleton<StorageService>(() => StorageService());
  getService.registerLazySingleton<DioClient>(() => DioClient(getService<StorageService>()));
  getService.registerLazySingleton<ApiService>(() => ApiService(getService<DioClient>()));
  getService.registerLazySingleton<NotificationService>(() => NotificationService());

  // BLoCs
  getService.registerFactory<AuthBloc>(() => AuthBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<BoardBloc>(() => BoardBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<CardBloc>(() => CardBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<NoteBloc>(() => NoteBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<PageBloc>(() => PageBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<SearchBloc>(() => SearchBloc(apiService: getService<ApiService>()));
  getService.registerFactory<SprintBloc>(() => SprintBloc(getService<ApiService>(), getService<StorageService>()));
  getService.registerFactory<ThemeBloc>(() => ThemeBloc(getService<StorageService>()));
  getService.registerLazySingleton<SuperthreadNotificationService>(() => SuperthreadNotificationService());
}