# JsEngine
JsEngine是基于webview_flutter插件内置的JS Runtime实现的JS扩展，能够实现动态运行JavaScript脚本，相比flutter_js等三方库更轻量级，不需要增加额外的size，能够支持JS HTTP网络请求、SP数据持久化以及对promise的支持。
由于本引擎是基于WebView内核实现，能够通过Google和AppStore审核。

## Http请求
JsEngine内置了网络请求接口，支持promise语法。

JS发起Http请求：
```javascript
HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
                  "wd": "%E6%97%A5%E5%8E%86"
              }, "GET").then((value) =>{
                console.log("sendRequest ok: ", value);
                run_callback(value);  // 返回数据到dart层
              });
```

## 数据存储
JsEngine内置支持数据以`key-value`的形式持久化存储，同时也支持promise语法。

JS存储和读取数据：
```javascript
SpStorage.set("ijk", "oh yep");
SpStorage.get("ijk").then((value) =>{
    console.log("SpStorage got ijk promise value:", value);
});
```

## 传参
⚠️ JsEngine约定以‘run_’前缀的变量名作为引擎内置的全局变量。
- 接口通过params进行传参，在JS脚本中可通过内置的`run_params`获取传入的运行参数:
```dart
JsEngine.runCode('console.log("run_params:", run_params);', params: 'dadada');
```
- 在JS中获取参数
```javascript
console.log("run_params:", run_params);
```

## 运行环境信息
获取JS运行环境的信息：
```dart
JsEngine.runCode('console.log("run_info:", run_info['system']);');
```

目前支持的信息包括：
|  字段名   | 定义  |
|  ----  | ----  |
| system  | 系统 |
| system_ver  | 系统版本 |
| locale  | 语言码 |
| engine_ver  | 引擎版本 |

## 预加载全局lib
默认情况下，`JsEngine.runCode()`是在隔离环境中运行，但JsEngine同时也支持全局模式：
```dart
JsEngine.loadLib('');
```

## 代理日志输出
代理日志能够让JS输出日志到dart层：
```dart
JsEngine.setLogProxy((tag, log) {
  print('$tag: $log');
});
```
JS调用
```javascript
run_log("hello world!");
```

## 完整示例
```dart
JsEngine.setDebugMode(true);
JsEngine.setLogProxy((tag, log) {
  print(log);
});
JsEngine.runCode('''
          console.log("run_params:", run_params);
          console.log("run_info:", run_info['system']);
          HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
                  "wd": "%E6%97%A5%E5%8E%86"
              }, "GET").then((value) =>{
                console.log("sendRequest ok: ", value);
                run_callback(value);
              });
          SpStorage.set("abc", "என்ன Yogi இப்படி சொல்லிட்ட |");
          SpStorage.set("ijk", "oh yep");
          SpStorage.get("abc").then((value) =>{
            console.log("SpStorage got abc promise value:", value);
          });
          SpStorage.get("ijk").then((value) =>{
            console.log("SpStorage got ijk promise value:", value);
          });
        ''', params: 'dadada', callback: (json) {
      logI('JsEngine-console runJsCode res: $json');
    }).then((json) {
      logI('JsEngine-console future runJsCode res: $json');
    });
```
---
作者：[Ruilin.Z](https://ruilin.github.io/blog/)

