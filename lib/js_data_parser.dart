import 'dart:convert';

import 'js_logger.dart';
import 'model/js_result.dart';
import 'model/js_http_model.dart';
import 'model/js_sp_model.dart';

/// js_data_parser
/// @Author ruilin
/// @Date 2024/3/20
///
/// @Description
class JsDataParser {
  static final JsDataParser _ = JsDataParser._internal();

  JsDataParser._internal();

  factory JsDataParser() {
    return _;
  }

  HttpRequestModel? parseHttpRequest(String json) {
    try {
      var map = jsonDecode(json);
      HttpRequestModel request = HttpRequestModel();
      request.id = map['id'].toString();
      request.url = map['url'];
      request.header = map['header'];
      request.data = map['data'];
      request.urlParams = map['urlParams'];
      request.method = (map['method'] ?? HttpMethod.GET) == HttpMethod.GET.name
          ? HttpMethod.GET
          : HttpMethod.POST;
      request.callbackFun = map['callbackFun'];
      return request;
    } catch (e) {
      logE('JsEngine parseHttpRequest error $e');
      return null;
    }
  }

  String? parseHttpResponse(id, HttpResponseModel res) {
    try {
      var resMap = {
        'code': res.httpResult.code,
        'message': res.httpResult.message,
        'id': id,
        'response': {}
      };
      if (res.response != null) {
        var resBody = res.response!.data;
        String data = '';
        if (resBody.runtimeType != String) {
          data = base64.encode(utf8.encode(jsonEncode(res.response!.data)));
        } else {
          data = base64.encode(utf8.encode(res.response!.data.toString()));
        }
        String header = base64.encode(
            utf8.encode(res.response!.headers.toString()));
        var response = {'headers': header, 'data': data};
        resMap['response'] = response;
      }
      return jsonEncode(resMap);
    } catch (e) {
      logE('JsEngine parseHttpResponse error $e');
      return null;
    }
  }

  SpReadModel? parseSpRead(String json) {
    try {
      var map = jsonDecode(json);
      SpReadModel model = SpReadModel();
      model.id = map['id'].toString();
      model.key = map['key'];
      model.callbackFun = map['callbackFun'];
      return model;
    } catch (e) {
      logE('JsEngine parseSpRead error $e');
      return null;
    }
  }

  String? parseSpReadResponse(id, value) {
    try {
      String data = base64.encode(utf8.encode(value));
      var map = {
        'id': id,
        'value': data,
      };
      return jsonEncode(map);
    } catch (e) {
      logE('JsEngine parseHttpResponse error $e');
      return null;
    }
  }

  bool checkHttpData(Map data) {
    return data.containsKey('url') && data.containsKey('header');
  }

  String genErrorResponse(JsResultCode httpResult) {
    var resMap = {
      'code': httpResult.code,
      'message': httpResult.message,
      'response': {}
    };
    return jsonEncode(resMap);
  }
}
