import 'package:dio/dio.dart';
import '../errors/app_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final backendMessage = _extractBackendMessage(err.response);

    if (status == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AuthError(backendMessage ?? "Session expired. Please login again."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status == 403) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AuthError(backendMessage ?? "You don't have permission for this action."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status == 409) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ConflictError(backendMessage ?? "Conflict detected. Reload or keep draft."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status == 400) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ValidationError(backendMessage ?? "Invalid request."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status == 402) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: QuotaExceededError(backendMessage ?? "Quota exceeded. Upgrade your plan or try again later."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status == 429) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: RateLimitError(backendMessage ?? "Too many requests. Please wait a minute and try again."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }
    if (status != null && status >= 500) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ServerError(backendMessage ?? "Server error. Please try again later."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }

    handler.next(err);
  }

  /// Parse backend ApiError-style body: { "message": string, "code": string, ... }.
  static String? _extractBackendMessage(Response? response) {
    final data = response?.data;
    if (data is! Map<String, dynamic>) return null;
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return null;
  }
}


