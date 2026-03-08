import 'dart:async';

Future<T> retry<T>(
  Future<T> Function() fn, {
  int retries = 2,
  Duration delay = const Duration(milliseconds: 300),
}) async {
  for (int attempt = 0; attempt <= retries; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt == retries) rethrow;
      await Future.delayed(delay);
    }
  }
  throw Exception("unreachable");
}


