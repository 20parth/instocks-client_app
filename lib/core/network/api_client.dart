import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/session_storage.dart';
import '../utils/error_handler.dart';

class ApiClient {
  ApiClient({required SessionStorage storage})
      : _storage = storage,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Global error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Show user-friendly error toast
          ErrorHandler.showErrorToast(error);
          // Pass the error along for specific handling if needed
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final SessionStorage _storage;

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response<dynamic>> post(String path, {Object? data}) {
    return _dio.post(path, data: data);
  }

  Future<Response<dynamic>> patch(String path, {Object? data}) {
    return _dio.patch(path, data: data);
  }
}
