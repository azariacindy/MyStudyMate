import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://192.168.0.116:8000'; // ✅ Tambahkan 
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return 'http://10.148.16.235:8000'; // ✅ Untuk iOS juga pakai IP + http://
  } else {
    return 'http://127.0.0.1:8000';
  }
}