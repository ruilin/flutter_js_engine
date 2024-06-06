import 'dart:io';

import 'js_logger.dart';


/// js_http_overrides
/// @Author ruilin
/// @Date 2024/3/29
///
/// @Description 忽略SSL证书
class JsHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    logD('JsHttpOverrides');
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}