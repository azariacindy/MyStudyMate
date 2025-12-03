import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  } else if (defaultTargetPlatform == TargetPlatform.android) {
 
    return 'http://192.168.0.105:8000'; 
  
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return 'http://10.148.16.235:8000';
  } else {
    return 'http://127.0.0.1:8000'; 
    //php artisan serve --host=0.0.0.0 --port=8000
    ////APIAI: sk-fdaa1392eba444dca1929a9c8ecd1e43
  }
}