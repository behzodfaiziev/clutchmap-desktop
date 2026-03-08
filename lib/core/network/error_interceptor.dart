import 'package:dio/dio.dart';
import '../errors/app_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    if (status == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AuthError("Session expired. Please login again."),
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
          error: AuthError("You don't have permission for this action."),
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
          error: ConflictError("Conflict detected. Reload or keep draft."),
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
          error: ServerError("Server error. Please try again later."),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }

    handler.next(err);
  }
}


