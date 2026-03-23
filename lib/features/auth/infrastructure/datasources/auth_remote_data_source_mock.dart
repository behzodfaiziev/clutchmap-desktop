import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'auth_remote_data_source.dart';

/// Mock implementation of [AuthRemoteDataSource] for development and testing.
///
/// This mock provides:
/// - Stateful user tracking (remembers logged-in user)
/// - Consistent user ID generation from email
/// - Optional error simulation for testing error paths
/// - No real API calls - all data is mocked
///
/// ## Usage Examples:
///
/// **Basic usage (default):**
/// ```dart
/// final mock = MockAuthRemoteDataSource();
/// final response = await mock.login('user@example.com', 'password');
/// ```
///
/// **Error simulation:**
/// ```dart
/// final mock = MockAuthRemoteDataSource(
///   shouldSimulateError: true,
///   errorMessage: 'Invalid credentials',
/// );
/// ```
///
/// **Manual user setup:**
/// ```dart
/// final mock = MockAuthRemoteDataSource();
/// mock.setCurrentUser(
///   id: 'user-123',
///   email: 'test@example.com',
///   displayName: 'Test User',
/// );
/// ```
///
/// **Reset state:**
/// ```dart
/// mock.reset(); // Clears logged-in user
/// ```
///
/// See also: [AuthRemoteDataSourceMockData] for reusable mock data payloads.

/// Shared mock payloads for auth API responses (tests or dev without hitting the real API).
abstract class AuthRemoteDataSourceMockData {
  static const String mockToken = 'mock_jwt_token_abc123';

  /// Default login response with standard mock user.
  static Map<String, dynamic> get loginResponse => {
        'token': mockToken,
        'user': {
          'id': 'mock-user-id',
          'email': 'mock@example.com',
          'displayName': 'Mock User',
        },
      };

  /// Default current user data.
  static Map<String, dynamic> get currentUser => {
        'id': 'mock-user-id',
        'email': 'mock@example.com',
        'displayName': 'Mock User',
      };

  /// Custom login response for a given email (use in tests or dev).
  static Map<String, dynamic> loginResponseWithEmail(String email, {String? displayName}) =>
      _loginResponseWithEmail(email, displayName);

  /// Custom current user map for a given id/email (use in tests or dev).
  static Map<String, dynamic> currentUserWith(String id, String email, {String? displayName}) =>
      _currentUserWith(id, email, displayName);

  /// Generate a user ID from an email (consistent hashing).
  static String userIdFromEmail(String email) {
    return 'user-${email.hashCode.abs()}';
  }
}

Map<String, dynamic> _loginResponseWithEmail(String email, [String? displayName]) => {
      'token': AuthRemoteDataSourceMockData.mockToken,
      'user': {
        'id': 'mock-user-id',
        'email': email,
        'displayName': displayName ?? 'Mock User',
      },
    };

Map<String, dynamic> _currentUserWith(String id, String email, [String? displayName]) => {
      'id': id,
      'email': email,
      'displayName': displayName,
    };

/// Mock [AuthRemoteDataSource] that returns [AuthRemoteDataSourceMockData] without calling the API.
/// Tracks the logged-in user so [getCurrentUser] returns the correct user data.
class MockAuthRemoteDataSource extends AuthRemoteDataSource {
  MockAuthRemoteDataSource({
    ApiClient? api,
    this.shouldSimulateError = false,
    this.errorMessage = 'Authentication failed',
  }) : super(api ?? _createDummyApiClient());

  static ApiClient _createDummyApiClient() => ApiClient(Dio());

  /// If true, [login] will throw an exception instead of succeeding.
  final bool shouldSimulateError;
  
  /// Error message to use when [shouldSimulateError] is true.
  final String errorMessage;

  /// Tracks the currently logged-in user based on the last login call.
  Map<String, dynamic>? _currentLoggedInUser;

  /// Generate a consistent user ID based on email (for realistic mock behavior).
  String _generateUserId(String email) {
    // Use a simple hash-like approach to generate consistent IDs
    return 'user-${email.hashCode.abs()}';
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (shouldSimulateError) {
      throw Exception(errorMessage);
    }

    // Generate a consistent user ID based on email
    final userId = _generateUserId(email);
    final response = {
      'token': AuthRemoteDataSourceMockData.mockToken,
      'user': {
        'id': userId,
        'email': email,
        'displayName': email.split('@').first,
      },
    };
    
    // Store the user data from login response for getCurrentUser()
    _currentLoggedInUser = Map<String, dynamic>.from(response['user'] as Map);
    return Map.from(response);
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (shouldSimulateError) {
      throw Exception(errorMessage);
    }

    // Return the logged-in user if available, otherwise return default
    if (_currentLoggedInUser != null) {
      return Map.from(_currentLoggedInUser!);
    }
    return Map.from(AuthRemoteDataSourceMockData.currentUser);
  }

  /// Reset the mock state (useful for testing).
  /// Clears the tracked logged-in user.
  void reset() {
    _currentLoggedInUser = null;
  }

  /// Set a specific user to be returned by [getCurrentUser].
  /// Useful for testing scenarios where you want to simulate an already logged-in user.
  void setCurrentUser({
    required String id,
    required String email,
    String? displayName,
  }) {
    _currentLoggedInUser = {
      'id': id,
      'email': email,
      'displayName': displayName,
    };
  }
}
