import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio dio = _build();

  Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // No lanzamos excepción en 4xx: las manejamos manualmente para leer el body
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('→ ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '← ${response.statusCode} ${response.requestOptions.uri}',
            );
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('✗ ${e.type} ${e.message}');
          }
          handler.next(e);
        },
      ),
    );

    return d;
  }

  /// Convierte una respuesta en data o lanza ApiException
  static dynamic unwrap(Response r) {
    final body = r.data;
    final status = r.statusCode ?? 0;

    if (body is Map && body['success'] == true) {
      return body['data'];
    }

    final msg = (body is Map && body['message'] is String)
        ? body['message'] as String
        : 'Error desconocido ($status)';

    final errors = (body is Map && body['errors'] is Map)
        ? Map<String, dynamic>.from(body['errors'])
        : null;

    throw ApiException(msg, statusCode: status, errors: errors);
  }
}
