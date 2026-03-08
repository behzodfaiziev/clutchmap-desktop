import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../websocket/websocket_service.dart';
import '../storage/token_storage.dart';
import '../logging/app_logger.dart';
import '../telemetry/telemetry.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // TokenStorage
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Dio with auth interceptor
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(baseUrl: "http://localhost:8080/api/v1"),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getIt<TokenStorage>().getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
    ));

    return dio;
  });

  // ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt()),
  );

  // WebSocketService
  getIt.registerLazySingleton<WebSocketService>(
    () => WebSocketService(),
  );

  // Logger
  getIt.registerLazySingleton<AppLogger>(
    () => AppLogger(),
  );

  // Telemetry
  getIt.registerLazySingleton<Telemetry>(
    () => ConsoleTelemetry(),
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      tokenStorage: getIt(),
    ),
  );
}

