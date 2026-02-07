import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../services/storage/storage_service.dart';
import '../services/api/api_service.dart';
import '../services/websocket/websocket_service.dart';
// import '../services/offline/offline_sync_service.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/notifications/superthread_notification_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Storage Service
  final storageService = StorageService();
  await storageService.init();
  sl.registerSingleton<StorageService>(storageService);

  // Dio Client
  final dioClient = DioClient(storageService);
  sl.registerSingleton<DioClient>(dioClient);

  // API Service
  final apiService = ApiService(dioClient);
  sl.registerSingleton<ApiService>(apiService);

  // WebSocket Service
  final webSocketService = WebSocketService();
  sl.registerSingleton<WebSocketService>(webSocketService);

  // Connectivity Service
  final connectivityService = ConnectivityService();
  await connectivityService.init();
  sl.registerSingleton<ConnectivityService>(connectivityService);

  // Notification Service
  final notificationService = SuperthreadNotificationService();
  sl.registerSingleton<SuperthreadNotificationService>(notificationService);
  await notificationService.initialize();

  // Offline Sync Service - Temporarily disabled
  // final offlineSyncService = OfflineSyncService(apiService, storageService);
  // await offlineSyncService.init();
  // sl.registerSingleton<OfflineSyncService>(offlineSyncService);
}

//便捷方法获取服务实例
T getService<T extends Object>() {
  return sl<T>();
}