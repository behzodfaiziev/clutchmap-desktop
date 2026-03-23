import 'package:flutter_test/flutter_test.dart';
import 'package:clutchmap_desktop/features/auth/infrastructure/datasources/auth_remote_data_source_mock.dart';
import 'package:clutchmap_desktop/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:clutchmap_desktop/core/storage/token_storage.dart';
import '../../../../helpers/in_memory_token_storage.dart';

void main() {
  group('MockAuthRemoteDataSource', () {
    late MockAuthRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      mockDataSource.reset();
    });

    tearDown(() {
      mockDataSource.reset();
    });

    test('login should return mock response with user data', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final response = await mockDataSource.login(email, password);

      // Assert
      expect(response, isA<Map<String, dynamic>>());
      expect(response['token'], isA<String>());
      expect(response['user'], isA<Map<String, dynamic>>());
      expect(response['user']['email'], equals(email));
      expect(response['user']['id'], isA<String>());
      expect(response['user']['displayName'], isA<String>());
    });

    test('login should generate consistent user ID for same email', () async {
      // Arrange
      const email = 'user@example.com';
      const password = 'password123';

      // Act
      final response1 = await mockDataSource.login(email, password);
      mockDataSource.reset();
      final response2 = await mockDataSource.login(email, password);

      // Assert
      expect(response1['user']['id'], equals(response2['user']['id']));
    });

    test('getCurrentUser should return logged-in user after login', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      await mockDataSource.login(email, password);

      // Act
      final currentUser = await mockDataSource.getCurrentUser();

      // Assert
      expect(currentUser['email'], equals(email));
      expect(currentUser['id'], isA<String>());
      expect(currentUser['displayName'], isA<String>());
    });

    test('getCurrentUser should return default user if no login occurred', () async {
      // Act
      final currentUser = await mockDataSource.getCurrentUser();

      // Assert
      expect(currentUser['email'], equals('mock@example.com'));
      expect(currentUser['id'], equals('mock-user-id'));
    });

    test('reset should clear logged-in user state', () async {
      // Arrange
      const email = 'test@example.com';
      await mockDataSource.login(email, 'password');
      
      // Act
      mockDataSource.reset();
      final currentUser = await mockDataSource.getCurrentUser();

      // Assert
      expect(currentUser['email'], equals('mock@example.com')); // Default user
    });

    test('setCurrentUser should set custom user data', () async {
      // Arrange
      const customId = 'custom-user-123';
      const customEmail = 'custom@example.com';
      const customDisplayName = 'Custom User';

      // Act
      mockDataSource.setCurrentUser(
        id: customId,
        email: customEmail,
        displayName: customDisplayName,
      );
      final currentUser = await mockDataSource.getCurrentUser();

      // Assert
      expect(currentUser['id'], equals(customId));
      expect(currentUser['email'], equals(customEmail));
      expect(currentUser['displayName'], equals(customDisplayName));
    });

    test('should throw error when shouldSimulateError is true', () async {
      // Arrange
      final errorMock = MockAuthRemoteDataSource(
        shouldSimulateError: true,
        errorMessage: 'Invalid credentials',
      );

      // Act & Assert
      expect(
        () => errorMock.login('test@example.com', 'password'),
        throwsException,
      );
      expect(
        () => errorMock.getCurrentUser(),
        throwsException,
      );
    });
  });

  group('AuthRepositoryImpl with MockAuthRemoteDataSource', () {
    late MockAuthRemoteDataSource mockDataSource;
    late AuthRepositoryImpl repository;
    late TokenStorage tokenStorage;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      tokenStorage = InMemoryTokenStorage();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockDataSource,
        tokenStorage: tokenStorage,
      );
      mockDataSource.reset();
    });

    tearDown(() async {
      await tokenStorage.clear();
      mockDataSource.reset();
    });

    test('login should save token and return user entity', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final user = await repository.login(email, password);

      // Assert
      expect(user.email, equals(email));
      expect(user.id, isNotEmpty);
      final savedToken = await tokenStorage.getToken();
      expect(savedToken, isNotNull);
      expect(savedToken, equals(AuthRemoteDataSourceMockData.mockToken));
    });

    test('getCurrentUser should return user when token exists', () async {
      // Arrange
      const email = 'test@example.com';
      await repository.login(email, 'password');

      // Act
      final user = await repository.getCurrentUser();

      // Assert
      expect(user, isNotNull);
      expect(user?.email, equals(email));
      expect(user?.id, isNotEmpty);
    });

    test('getCurrentUser should return null when no token exists', () async {
      // Act
      final user = await repository.getCurrentUser();

      // Assert
      expect(user, isNull);
    });

    test('validateToken should return user when valid token exists', () async {
      // Arrange
      const email = 'test@example.com';
      await repository.login(email, 'password');

      // Act
      final user = await repository.validateToken();

      // Assert
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });

    test('validateToken should return null when no token exists', () async {
      // Act
      final user = await repository.validateToken();

      // Assert
      expect(user, isNull);
    });

    test('logout should clear token', () async {
      // Arrange
      const email = 'test@example.com';
      await repository.login(email, 'password');
      expect(await tokenStorage.getToken(), isNotNull);

      // Act
      await repository.logout();

      // Assert
      expect(await tokenStorage.getToken(), isNull);
    });
  });

  group('AuthRemoteDataSourceMockData', () {
    test('loginResponse should have correct structure', () {
      // Act
      final response = AuthRemoteDataSourceMockData.loginResponse;

      // Assert
      expect(response['token'], equals(AuthRemoteDataSourceMockData.mockToken));
      expect(response['user'], isA<Map<String, dynamic>>());
      expect(response['user']['id'], isA<String>());
      expect(response['user']['email'], isA<String>());
    });

    test('loginResponseWithEmail should use provided email', () {
      // Arrange
      const email = 'custom@example.com';

      // Act
      final response = AuthRemoteDataSourceMockData.loginResponseWithEmail(email);

      // Assert
      expect(response['user']['email'], equals(email));
    });

    test('userIdFromEmail should generate consistent IDs', () {
      // Arrange
      const email = 'test@example.com';

      // Act
      final id1 = AuthRemoteDataSourceMockData.userIdFromEmail(email);
      final id2 = AuthRemoteDataSourceMockData.userIdFromEmail(email);

      // Assert
      expect(id1, equals(id2));
      expect(id1, startsWith('user-'));
    });
  });
}
