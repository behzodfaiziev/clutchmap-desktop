sealed class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

/// Validation or bad-request error from backend (e.g. 400 with message).
class ValidationError extends AppError {
  const ValidationError(super.message);
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

/// Quota exceeded (HTTP 402). Upgrade or wait for reset.
class QuotaExceededError extends AppError {
  const QuotaExceededError(super.message);
}

/// Rate limit exceeded (HTTP 429). Try again later.
class RateLimitError extends AppError {
  const RateLimitError(super.message);
}


