import 'package:dio/dio.dart';

import 'js_result.dart';

/// http_request
/// @Author ruilin
/// @Date 2024/3/20
///
/// @Description TODO
class HttpRequestModel {
  String id = '';
  String url = '';
  Map<String, dynamic>? header;
  Map<String, dynamic>? data;
  Map<String, dynamic>? urlParams;
  HttpMethod method = HttpMethod.GET;
  String? callbackFun;
}

class HttpResponseModel<T> {
  JsResultCode httpResult = JsResult.SUCCESS;
  Response<T>? response;
}

enum HttpMethod {
  GET,
  POST
}