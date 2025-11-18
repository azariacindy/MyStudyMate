import 'package:dio/dio.dart';
import '../config/api_constant.dart';

class DioClient {
  static final Dio _dio = Dio();

  static Dio getInstance() {
    String cleanBaseUrl = baseUrl.replaceAll(RegExp(r'/$'), '');
    _dio.options.baseUrl = '$cleanBaseUrl/api/'; // ✅ Bersih, tanpa spasi

    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.contentType = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Add logging interceptor for debugging
    _dio.interceptors.clear();
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
      request: true,
      logPrint: (obj) => print('🔵 DIO: $obj'),
    ));

    return _dio;
  }
}