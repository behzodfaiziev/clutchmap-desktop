import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../websocket/websocket_service.dart';
import '../storage/token_storage.dart';
import '../logging/app_logger.dart';
import '../telemetry/telemetry.dart';
import '../config/mock_config.dart';
import '../config/api_config.dart';
import '../team/active_team_service.dart';
import '../team/team_remote_data_source.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source_mock.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/settings/infrastructure/datasources/system_remote_data_source.dart';
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_data_source.dart';
import '../../features/matches/infrastructure/datasources/matches_remote_data_source.dart';
import '../../features/opponents/infrastructure/datasources/opponent_remote_data_source.dart';
import '../../features/workspace/infrastructure/datasources/workspace_remote_data_source.dart';
import '../../features/workspace/infrastructure/datasources/share_remote_data_source.dart';
import '../../features/workspace/infrastructure/datasources/export_remote_data_source.dart';
import '../../features/templates/infrastructure/datasources/template_remote_data_source.dart';
import '../../features/comparison/infrastructure/datasources/comparison_remote_data_source.dart';
import '../../features/search/infrastructure/datasources/search_remote_data_source.dart';
import '../../features/benchmark/infrastructure/datasources/benchmark_remote_data_source.dart';
import '../../features/ai_coach/infrastructure/datasources/ai_coach_remote_data_source.dart';
import '../../features/capabilities/infrastructure/datasources/capabilities_remote_data_source.dart';
import '../../features/game/infrastructure/datasources/game_config_remote_data_source.dart';
import '../../features/organization/infrastructure/datasources/organization_remote_data_source.dart';
import '../../features/library/infrastructure/datasources/folder_remote_data_source.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Logger (register first so it can be used for logging)
  getIt.registerLazySingleton<AppLogger>(
    () => AppLogger(),
  );

  // Log mock configuration
  final logger = getIt<AppLogger>();
  if (MockConfig.useMockAuth) {
    logger.info('Using MockAuthRemoteDataSource for authentication');
  } else {
    logger.info('Using real AuthRemoteDataSource for authentication');
  }

  // TokenStorage
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Dio with auth and X-Team-Id interceptors (resolves ActiveTeamService at request time)
  // Register ActiveTeamService after ApiClient/TeamRemoteDataSource below
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeoutMs),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getIt<TokenStorage>().getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        final teamId = getIt<ActiveTeamService>().activeTeamId;
        if (teamId != null && teamId.isNotEmpty) {
          options.headers["X-Team-Id"] = teamId;
        }
        handler.next(options);
      },
    ));

    return dio;
  });

  // ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>()),
  );

  // Teams (GET /teams/me)
  getIt.registerLazySingleton<TeamRemoteDataSource>(
    () => TeamRemoteDataSource(getIt<ApiClient>()),
  );

  // Active team (for X-Team-Id header). Many backend endpoints require it.
  getIt.registerLazySingleton<ActiveTeamService>(
    () => ActiveTeamService(getIt<AppLogger>(), getIt<TeamRemoteDataSource>()),
  );

  // System (health, capabilities)
  getIt.registerLazySingleton<SystemRemoteDataSource>(
    () => SystemRemoteDataSource(getIt<ApiClient>()),
  );

  // Feature data sources (use same ApiClient → auth + X-Team-Id + error handling)
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<MatchesRemoteDataSource>(
    () => MatchesRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<OpponentRemoteDataSource>(
    () => OpponentRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ShareRemoteDataSource>(
    () => ShareRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ExportRemoteDataSource>(
    () => ExportRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<TemplateRemoteDataSource>(
    () => TemplateRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ComparisonRemoteDataSource>(
    () => ComparisonRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BenchmarkRemoteDataSource>(
    () => BenchmarkRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AiCoachRemoteDataSource>(
    () => AiCoachRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CapabilitiesRemoteDataSource>(
    () => CapabilitiesRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<GameConfigRemoteDataSource>(
    () => GameConfigRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<OrganizationRemoteDataSource>(
    () => OrganizationRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<FolderRemoteDataSource>(
    () => FolderRemoteDataSource(getIt<ApiClient>()),
  );

  // WebSocketService
  getIt.registerLazySingleton<WebSocketService>(
    () => WebSocketService(),
  );


  // Telemetry
  getIt.registerLazySingleton<Telemetry>(
    () => ConsoleTelemetry(),
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => MockConfig.useMockAuth
        ? MockAuthRemoteDataSource()
        : AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      tokenStorage: getIt(),
      activeTeamService: getIt<ActiveTeamService>(),
    ),
  );
}

