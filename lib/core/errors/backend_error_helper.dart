import 'package:dio/dio.dart';
import 'app_error.dart';

/// Extracts a user-facing message from an exception thrown by API calls.
///
/// Prefers [AppError.message] (set by [ErrorInterceptor]), then
/// `response.data['message']`, then [fallback] or [e.toString].
String messageFromException(Object e, {String fallback = 'Something went wrong'}) {
  if (e is DioException) {
    if (e.error != null && e.error is AppError) {
      return (e.error! as AppError).message;
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
  }
  return fallback;
}
