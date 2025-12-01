import 'package:dio/dio.dart';
import '../config/api_constant.dart';

class StudyCardService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // TODO: Implement study card service methods here
}
