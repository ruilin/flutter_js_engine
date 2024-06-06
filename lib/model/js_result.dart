import 'package:dio/dio.dart';

import '../js_logger.dart';

/// http_exception
/// @Author ruilin
/// @Date 2023/12/5
///
/// @Description 网络异常定义
class JsResult {
  /// 成功
  static final SUCCESS = JsResultCode('0', 'Success!');
  /// 连接失败（无网络）
  static final CONNECTION_ERR = JsResultCode('F0001', 'Connection Error');
  /// 连接超时
  static final CONNECTION_TIMEOUT = JsResultCode('F0002', 'Connection Timeout');
  /// 请求超时
  static final REQUEST_TIMEOUT = JsResultCode('F0003', 'Request Timeout');
  /// 证书无效
  static final BAD_CERTIFICATE = JsResultCode('F0004', 'Bad Certificate');
  /// 无效响应
  static final BAD_RESPONSE = JsResultCode('F0005', 'Bad Response');
  /// 数据异常
  static final DATA_ERROR = JsResultCode('F0006', 'Data Error');
  /// 请求参数异常
  static final PARAMS_ERR = JsResultCode('F0007', 'Params Error');
  /// 未知网络错误
  static final UNKNOWN_ERR = JsResultCode('F9999', 'Unknown Http Error');
  /// 服务错误：证书校验失败
  static final SER_TOKEN_ERR = JsResultCode('401', 'Token Error');

  /// 没数据
  static final NO_DATA = JsResultCode('P0001', 'No Data');
  /// YouTube cookie错误
  static final COOKIE_ERR = JsResultCode('P0002', 'Cookie Error');
  /// 脚本找不到
  static final JS_NOT_FOUND = JsResultCode('P0003', 'API not found');
  /// 未知异常
  static final UNKNOWN_EXC = JsResultCode('P9999', 'Unknown Exception');

  /// 运行超时
  static final RUN_CODE_TIMEOUT = JsResultCode('J0001', 'RunCode Timeout');
  /// 运行异常
  static final RUN_CODE_EXC = JsResultCode('J0002', 'RunCode Exception');


  static fromDio(DioException e) {
    logI(tag: 'HTTP_INFO', 'exceptionType: ${e.type}');
    switch (e.type) {
      case DioExceptionType.connectionError:
        return CONNECTION_ERR;
      case DioExceptionType.connectionTimeout:
        return CONNECTION_TIMEOUT;
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return REQUEST_TIMEOUT;
      case DioExceptionType.badCertificate:
        return BAD_CERTIFICATE;
      case DioExceptionType.badResponse:
        return BAD_RESPONSE;
      default:
        return UNKNOWN_ERR;
    }
  }

  static fromException(Object e) {
    return JsResultCode(UNKNOWN_EXC.code, e.toString());
  }

  static fromRunCodeException(Object e) {
    return JsResultCode(RUN_CODE_EXC.code, e.toString());
  }
}

class JsResultCode {
  // 错误码
  final String code;
  // 提示信息
  final String message;
  JsResultCode(this.code, this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 检查是否是同一个对象
    return other is JsResultCode && other.code == code; // 比较错误码
  }

  @override
  int get hashCode => code.hashCode; // hashCode 属性的实现
}