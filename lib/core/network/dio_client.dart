import 'package:dio/dio.dart';
import 'package:shop_kart/core/constants/api_constants.dart';

Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));

  return dio;
}
