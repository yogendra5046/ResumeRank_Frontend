import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class DioClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  DioClient(this.dio, this.localDataSource) {
    dio
      ..options.baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '').isNotEmpty 
          ? const String.fromEnvironment('API_BASE_URL') 
          : 'https://resumerankappbackend-production.up.railway.app/v1'
      ..options.connectTimeout = const Duration(seconds: 120)
      ..options.receiveTimeout = const Duration(seconds: 120)
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Add API Key for backend validation
            options.headers['X-API-Key'] = 'rr-client-mobile-app-prod';

            // Add JWT Token if user is logged in
            final token = await localDataSource.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      )
      ..interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          responseBody: true,
          error: true,
        ),
      );
  }
}
