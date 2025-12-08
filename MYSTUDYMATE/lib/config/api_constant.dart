String get baseUrl {
  // Production URL (Laravel Cloud)
  return 'https://hostinglaravelcloud-production-slswfh.laravel.cloud';
  
  // Local development (comment out when testing production)
  // if (kIsWeb) {
  //   return 'http://127.0.0.1:8000';
  // } else if (defaultTargetPlatform == TargetPlatform.android) {
  //   return 'http://192.168.106.113:8000';
  // } else if (defaultTargetPlatform == TargetPlatform.iOS) {
  //   return 'http://192.168.106.113:8000';
  // } else {
  //   return 'http://127.0.0.1:8000';
  // }
}