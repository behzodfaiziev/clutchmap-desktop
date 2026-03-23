import 'package:flutter_test/flutter_test.dart';
import 'package:clutchmap_desktop/features/auth/domain/repositories/auth_repository.dart';
import 'package:clutchmap_desktop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clutchmap_desktop/features/auth/presentation/bloc/auth_event.dart';
import 'package:clutchmap_desktop/features/auth/presentation/bloc/auth_state.dart';
import 'package:clutchmap_desktop/features/auth/infrastructure/datasources/auth_remote_data_source_mock.dart';
import 'package:clutchmap_desktop/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../../../helpers/in_memory_token_storage.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc bloc;
    late AuthRepository repository;
    late MockAuthRemoteDataSource mockDataSource;
    late InMemoryTokenStorage tokenStorage;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      tokenStorage = InMemoryTokenStorage();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockDataSource,
        tokenStorage: tokenStorage,
      );
      bloc = AuthBloc(authRepository: repository);
      mockDataSource.reset();
    });

    tearDown(() async {
      await bloc.close();
      await tokenStorage.clear();
      mockDataSource.reset();
    });

    group('AppStarted', () {
      test('emits [AuthLoading, AuthUnauthenticated] when no token exists', () async {
        final states = <AuthState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(AppStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states[1], isA<AuthUnauthenticated>());
        await subscription.cancel();
      });

      test('emits [AuthLoading, AuthAuthenticated] when valid token exists', () async {
        await repository.login('test@example.com', 'password');
        final states = <AuthState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(AppStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states[1], isA<AuthAuthenticated>());
        expect((states[1] as AuthAuthenticated).user.email, equals('test@example.com'));
        await subscription.cancel();
      });
    });

    group('LoginRequested', () {
      test('emits [AuthLoading, AuthAuthenticated] on success', () async {
        final states = <AuthState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const LoginRequested(
          email: 'user@example.com',
          password: 'password123',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states[1], isA<AuthAuthenticated>());
        expect((states[1] as AuthAuthenticated).user.email, equals('user@example.com'));
        expect((states[1] as AuthAuthenticated).user.id, isNotEmpty);
        await subscription.cancel();
      });

      test('emits [AuthLoading, AuthFailure] when login throws', () async {
        final errorRepository = AuthRepositoryImpl(
          remoteDataSource: MockAuthRemoteDataSource(shouldSimulateError: true),
          tokenStorage: tokenStorage,
        );
        final errorBloc = AuthBloc(authRepository: errorRepository);
        addTearDown(() => errorBloc.close());

        final states = <AuthState>[];
        final subscription = errorBloc.stream.listen(states.add);

        errorBloc.add(const LoginRequested(
          email: 'user@example.com',
          password: 'wrong',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<AuthLoading>());
        expect(states[1], isA<AuthFailure>());
        expect((states[1] as AuthFailure).message, isNotEmpty);
        await subscription.cancel();
      });
    });

    group('LogoutRequested', () {
      test('emits AuthUnauthenticated', () async {
        await repository.login('test@example.com', 'password');
        final states = <AuthState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(LogoutRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(1));
        expect(states.last, isA<AuthUnauthenticated>());
        await subscription.cancel();
      });

      test('clears token so next AppStarted emits AuthUnauthenticated', () async {
        await repository.login('test@example.com', 'password');
        bloc.add(LogoutRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final states = <AuthState>[];
        final subscription = bloc.stream.listen(states.add);
        bloc.add(AppStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.any((s) => s is AuthUnauthenticated), isTrue);
        await subscription.cancel();
      });
    });
  });
}
