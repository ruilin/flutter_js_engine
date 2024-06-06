
# JsEngine
JsEngine is a JavaScript extension based on the webview_flutter plugin's built-in JS Runtime. It allows dynamic execution of JavaScript scripts and is more lightweight compared to third-party libraries like flutter_js. It does not require additional size, supports JS HTTP network requests, SP data persistence, and promises. As it is implemented based on the WebView kernel, it can pass Google and AppStore reviews.

## HTTP Requests
JsEngine has built-in network request interfaces that support promise syntax.

JS HTTP Request Example:

```javascript
HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
                  "wd": "%E6%97%A5%E5%8E%86"
              }, "GET").then((value) =>{
                console.log("sendRequest ok: ", value);
                run_callback(value);  // Return data to Dart layer
              });
```

## Data Storage
JsEngine supports persistent data storage in a key-value format, also supporting promise syntax.

JS Store and Retrieve Data Example:

```javascript
SpStorage.set("ijk", "oh yep");
SpStorage.get("ijk").then((value) =>{
    console.log("SpStorage got ijk promise value:", value);
});
```

## Parameter Passing
⚠️ JsEngine uses variables with the 'run_' prefix as built-in global variables.

Interfaces pass parameters via params, which can be accessed in JS scripts through the built-in run_params:
```dart
JsEngine.runCode('console.log("run_params:", run_params);', params: 'dadada');
Accessing parameters in JS:
```
```javascript
console.log("run_params:", run_params);
```

## Runtime Information
Retrieve JS runtime environment information:

```dart
JsEngine.runCode('console.log("run_info:", run_info['system']);');
```

Supported information includes:

|Field Name	| Definition
|  ----  | ----  |
|system	| System
|system_ver	| System Version
|locale	| Language Code
|engine_ver	| Engine Version

## Preload Global Library

By default, JsEngine.runCode() runs in an isolated environment, but JsEngine also supports a global mode:

```dart
JsEngine.loadLib('');
```

## Proxy Log Output
Proxy logs allow JS logs to be output to the Dart layer:

```dart
JsEngine.setLogProxy((tag, log) {
  print('$tag: $log');
});
```
JS Call:

```javascript
run_log("hello world!");
```

## Complete Example
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
[Ruilin.z](https://ruilin.github.io/blog/)