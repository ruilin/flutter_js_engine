import 'package:dio/dio.dart';
import 'js_logger.dart';
import 'model/js_result.dart';
import 'model/js_http_model.dart';

class JsHttp {
  static final JsHttp _ = JsHttp._internal();
  JsHttp._internal();

  factory JsHttp() {
    return _;
  }

  final _dioHttp = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<HttpResponseModel<T>> sendRequest<T>(HttpRequestModel requestBean) async {
    var res = HttpResponseModel<T>();
    try {
      Response<T> response = await _dioHttp.request<T>(requestBean.url,
          data: requestBean.data,
          queryParameters: requestBean.urlParams,
          options: Options(
              headers: requestBean.header, method: requestBean.method.name));
      res.response = response;
      res.httpResult = JsResult.SUCCESS;
    } on DioException catch(e) {
      logE('sendRequest DioException ${e.type.name}');
      res.httpResult = JsResult.fromDio(e);
    } catch(e) {
      logE('sendRequest Exception $e');
      res.httpResult = JsResult.fromException(e);
    }
    return Future.value(res);
  }
}
