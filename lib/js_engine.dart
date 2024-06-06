library js_engine;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// #docregion platform_imports
// Import for Android features.

// Import for iOS features.
import 'js_data_parser.dart';
import 'js_device.dart';
import 'js_http.dart';
import 'js_http_overrides.dart';
import 'js_utils.dart';
import 'jscode/js_lib.dart';
import 'js_logger.dart';
import 'model/js_result.dart';

/// js_engine
/// @Author ruilin
/// @Date 2024/3/20
///
/// @Description JS引擎
class JsEngine {
  static const _VERSION = '1.1.0';
  static const _TAG = 'JsEngine-console';
  static const _CHANNEL_HTTP = 'ChannelHttp';
  static const _CHANNEL_CALLBACK = 'ChannelCallback';
  static const _CHANNEL_SAVE = 'ChannelSave';
  static const _CHANNEL_READ = 'ChannelRead';
  static const _CHANNEL_LOG = 'ChannelLog';

  /// 引擎内置JS参数
  static const JS_RUN_PARAMS = 'run_params';
  static const JS_RUN_INFO = 'run_info';

  /// 运行超时时间（秒）
  static const _TIMEOUT_S = 30;
  static final _sp = SharedPreferences.getInstance();
  static final Map<String, JsEngine> _runBufferMap = {};
  static WebViewController? _jsRuntime;
  static bool _debugMode = false;
  String _runId = '';
  OnJsCallback? _callback;
  Completer<String>? _completer;
  static final Completer<bool> _iosRuntimeReady = Completer();

  JsEngine._();

  static Future<String> get version async {
    return _VERSION;
  }

  Future<WebViewController> _getJsRuntime() async {
    JsLogger.init(superTag: _TAG);
    if (_jsRuntime != null) {
      return _jsRuntime!;
    }
    _jsRuntime = await _createJsRuntime();
    return _jsRuntime!;
  }

  /// 内置库
  Future<void> _loadInnerLibs(runtime) async {
    var deviceInfo = await JsDevice.getDeviceInfo();
    var deviceInfoJson = jsonEncode(deviceInfo);
    JsLib.load(runtime, deviceInfo: deviceInfoJson);
  }

  Future<WebViewController> _createJsRuntime() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller = WebViewController
        .fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(_CHANNEL_HTTP,
          onMessageReceived: (JavaScriptMessage message) {
        // logI(tag: _TAG, 'JsEngine parseHttpRequest message=${message.message}');
        var request = JsDataParser().parseHttpRequest(message.message);
        if (request != null) {
          logI(tag: _TAG, 'JsEngine sendRequest');
          // 忽略证书校验
          HttpOverrides.runWithHttpOverrides(() {
            JsHttp().sendRequest<String>(request).then((res) {
              String? json = JsDataParser().parseHttpResponse(request.id, res);
              // logD(tag: _TAG, 'JsEngine call onHttpResponse json=${json}');
              if (request.callbackFun != null) {
                logI(
                    tag: _TAG,
                    'JsEngine call callbackFun ${request.callbackFun}');
                _execute("${request.callbackFun}(`${json ?? ''}`)");
              }
            });
          }, JsHttpOverrides());
        }
      })
      ..addJavaScriptChannel(_CHANNEL_CALLBACK,
          onMessageReceived: (JavaScriptMessage message) {
        var map = jsonDecode(message.message.toString());
        var runId = map['runId'];
        var result = map['result'];
        var run = _runBufferMap[runId];
        if (run != null) {
          if (run._callback != null) {
            run._callback!(result);
          }
          run._doComplete(result);
        } else {
          logI(tag: _TAG, 'JsEngine js callback not found : $runId');
        }
      })
      ..addJavaScriptChannel(_CHANNEL_SAVE,
          onMessageReceived: (JavaScriptMessage message) {
        var map = jsonDecode(message.message.toString());
        _sp.then((sp) {
          sp.setString(map['key'], map['value']);
        });
      })
      ..addJavaScriptChannel(_CHANNEL_READ,
          onMessageReceived: (JavaScriptMessage message) async {
        var model = JsDataParser().parseSpRead(message.message);
        if (model != null) {
          var value = (await _sp).getString(model.key) ?? '';
          var json = JsDataParser().parseSpReadResponse(model.id, value);
          if (model.callbackFun != null) {
            logI(tag: _TAG, 'JsEngine call callbackFun ${model.callbackFun}');
            _execute('${model.callbackFun}(`${json ?? ''}`)');
          }
        }
      })
      ..addJavaScriptChannel(_CHANNEL_LOG,
          onMessageReceived: (JavaScriptMessage message) {
        var log = message.message.toString();
        logI(tag: _TAG, '[JS]$log');
      });

    if (Platform.isIOS || Platform.isMacOS) {
      controller
        ..setNavigationDelegate(
          NavigationDelegate(
              onPageStarted: (String url) {
                _loadInnerLibs(controller).then((value) {
                  _iosRuntimeReady.complete(true);
                });
              },
              onPageFinished: (String url) {}),
        )
        ..loadHtmlString('''
          <!DOCTYPE html>
          <html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>JsEngine</title>
          </head>
          <body>
              <h1>Hello, JsEngine!</h1>
              <p>JsEngine opens a new window for you.</p>
          </body>
          </html>
        ''');
    } else {
      _loadInnerLibs(controller);
    }

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(_debugMode);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    } else if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }

    return controller;
  }

  /// 执行代码
  Future<void> _execute(String code) async {
    await (await _getJsRuntime()).runJavaScript(code).catchError((error) {
      logE(tag: _TAG, 'runCode error: $error');
      _doComplete(JsDataParser()
          .genErrorResponse(JsResult.fromRunCodeException(error)));
    });
  }

  static Future<String> _doTask(String code,
      {String? params, bool isSandbox = true, OnJsCallback? callback}) async {
    Completer<String> completer = Completer();
    Future<String> future = completer.future;
    if (params != null) {
      code = 'let $JS_RUN_PARAMS = `$params`;\n$code';
    }
    var runId = JsUtils.generateRandomId(6);
    logI(tag: _TAG, 'JsEngine start runId=$runId');
    if (isSandbox) {
      // 沙盒模式
      code = '''
        (function() {
            function run_callback(json) {
              let format = {
                'runId': '$runId',
                'result': json
              };
              let jsonString = JSON.stringify(format);
              ChannelCallback.postMessage(jsonString); 
            }
            $code
        })();
      ''';

      var engine = JsEngine._();
      _runBufferMap[runId] = engine;
      engine._runId = runId;
      engine._callback = callback;
      engine._completer = completer;
      engine._execute(code);

      Future.delayed(const Duration(seconds: _TIMEOUT_S), () {
        engine._doComplete(
            JsDataParser().genErrorResponse(JsResult.RUN_CODE_TIMEOUT));
      });
      return future;
    } else {
      // 非沙盒模式
      var engine = JsEngine._();
      await engine._execute(code);
      return JsDataParser().genErrorResponse(JsResult.SUCCESS);
    }
  }

  _doComplete(result) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer?.complete(result);
    }
    if (_runBufferMap.containsKey(_runId)) {
      _runBufferMap.remove(_runId);
    }
  }

  /// 加载JS库，请勿重复加载相同的code
  static Future<String> loadLib(String code) {
    if (Platform.isIOS || Platform.isMacOS) {
      return _iosRuntimeReady.future.then((value) {
        return _doTask(code, isSandbox: false);
      });
    } else {
      return _doTask(code, isSandbox: false);
    }
  }

  /// 运行代码
  static Future<String> runCode(String code,
      {String? params, OnJsCallback? callback}) {
    return _doTask(code, params: params, callback: callback);
  }

  static void clear() {
    _jsRuntime = null;
  }

  /// 设置日志输出代理
  static setLogProxy(OnLogProxy proxy) {
    JsLogger().setLogProxy(proxy);
  }

  static setDebugMode(debugMode) {
    _debugMode = debugMode;
  }
}

typedef OnJsCallback = void Function(String result);
