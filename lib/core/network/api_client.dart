import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'error_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Request to API base URL (paths under /api/v1).
  Future<Response> get(String path) async {
    return _dio.get(path);
  }

  /// GET request that returns response body as bytes (e.g. for PDF export).
  Future<Uint8List> getBytes(String path) async {
    final response = await _dio.get<Uint8List>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null) throw Exception('Empty response');
    return data;
  }

  Future<Response> post(String path, dynamic data) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, dynamic data) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  /// Request to public base URL (e.g. /public/v1/match/{token}).
  /// Use for endpoints that are not under /api/v1.
  Future<Response> getPublic(String path) async {
    final url = ApiConfig.publicRootUrl + (path.startsWith('/') ? path : '/$path');
    return _dio.get(url);
  }
}


