sealed class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class AuthError extends AppError {
  const AuthError(super.message);
}

class ConflictError extends AppError {
  const ConflictError(super.message); // version conflict / lock conflict
}

class ServerError extends AppError {
  const ServerError(super.message);
}


