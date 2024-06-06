import 'dart:io';

/// build
/// @Author ruilin
/// @Date 2024/4/2
///
/// @Description 脚本：把JS转换生成dart代码
void main(List<String> arguments) async {
  Directory currentDirectory = Directory.current;

  var dartFile = File('${currentDirectory.path}/js_lib.dart');
  if (dartFile.existsSync()) {
    dartFile.delete();
    dartFile.create();
  }

  print('create dartFile: ${dartFile.path}');
  List<FileSystemEntity> files = currentDirectory.listSync();
  int i = 0;
  var dartCode = '';
  var loadCode = '';
  for (var file in files) {
    if (file is File && file.path.endsWith('.js')) {
      try {
        // 读取文件内容
        String jsCode = await file.readAsString();

        String fileName = file.path.split('/').last.split('.').first;

        dartCode +=
            '''static var $fileName = \'\'\'\n${escapeSpecialCharacters(jsCode)}\'\'\';\n''';
        loadCode += '\${$fileName}\\n';
        print('build: $fileName');
      } catch (e) {
        print('Error reading file: $e');
      }
      i++;
    }
  }
  dartFile.writeAsStringSync(
      '''import '../js_engine.dart';\n///AUTO GENERATED\n///@Author ruilin\nclass JsLib {\n$dartCode
static load(var jsRuntime, {deviceInfo}) {
  var code = '$loadCode';
  if (deviceInfo != null) {code = '\$code\\nlet \${JsEngine.JS_RUN_INFO} = \$deviceInfo;';} 
    jsRuntime.runJavaScript(code);
  }
}
  ''');
  print('total count: $i');
}

String escapeSpecialCharacters(String input) {
  // 定义需要转义的特殊字符
  final RegExp specialChars = RegExp(r'[$]');
  // 将特殊字符前面加上转义符 \
  return input.replaceAllMapped(specialChars, (match) => '\\${match.group(0)}');
}
