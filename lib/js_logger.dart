import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// log_manager
/// @Author ruilin
/// @Date 2023/9/28
///
/// @Description 日志管理
class JsLogger {
  static String TAG = '';
  static Logger? logger;
  static OnLogProxy? _logProxy;
  static bool isInited = false;

  static init({superTag = 'JS-Engine'}) {
    if (isInited) {
      return;
    }
    isInited = true;
    TAG = superTag;
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
    });
    logger = Logger(TAG);
  }

  static Future<Directory> _createDir(path) async {
    var dir = Directory(path);
    try {
      bool exists = await dir.exists();
      if (!exists) {
        await dir.create();
      }
    } catch (e) {
      logE('_getLogFilePath error: $e');
    }
    return dir;
  }

  setLogProxy(OnLogProxy proxy) {
    _logProxy = proxy;
  }
}

_makeMsg(msg, String? tag) {
  return '[${JsLogger.TAG}]${tag != null ? '[$tag]' : ''} $msg';
}

/// Level: Debug
logD(msg, {String? tag}) {
  // if (!kReleaseMode)
  if (JsLogger._logProxy != null) {
    JsLogger._logProxy!(tag, msg);
  } else {
    JsLogger.logger?.fine(_makeMsg(msg, tag));
  }
}

/// Level: Info
logI(msg, {String? tag}) {
  if (JsLogger._logProxy != null) {
    JsLogger._logProxy!(tag, msg);
  } else if (JsLogger.isInited) {
    JsLogger.logger?.info(_makeMsg(msg, tag));
  } else if (kDebugMode) {
    print(_makeMsg(msg, tag));
  }
}

/// Level: Error
logE(msg, {String? tag}) {
  if (JsLogger._logProxy != null) {
    JsLogger._logProxy!(tag, msg);
  } else if (JsLogger.isInited) {
    JsLogger.logger?.severe(_makeMsg(msg, tag));
  } else if (kDebugMode) {
    print(_makeMsg(msg, tag));
  }
}

typedef OnLogProxy = void Function(String? tag, String log);
