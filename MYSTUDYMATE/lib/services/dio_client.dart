import 'package:dio/dio.dart';
import '../config/api_constant.dart';

class DioClient {
  static final Dio _dio = Dio();

  static Dio getInstance() {
    String cleanBaseUrl = baseUrl.replaceAll(RegExp(r'/$'), '');
    _dio.options.baseUrl = '$cleanBaseUrl/api/'; // ✅ Bersih, tanpa spasi

    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.contentType = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    return _dio;
  }
}