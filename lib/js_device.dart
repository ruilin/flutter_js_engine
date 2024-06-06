import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// js_device
/// @Author ruilin
/// @Date 2024/4/3
///
/// @Description
class JsDevice {
  static PackageInfo? _packageInfo;

  static Future<Map<String, String>> getDeviceInfo() async {
    var info = (await packageInfo);
    Map<String, String> map = {
      'system': Platform.isAndroid ? 'android' : 'ios',
      'system_ver': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'engine_ver': info.version,
    };
    return map;
  }

  static Future<PackageInfo> get packageInfo async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }
}