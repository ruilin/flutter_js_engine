// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:js_engine/js_engine.dart';
// import 'package:js_engine/log_manager.dart';
//
// void main() {
//   test('Test JsEngine', () async {
//     // 执行 JavaScript 代码并等待异步结果
//     String res = await JsEngine.runCode('''
//           console.log("run_params:", run_params);
//           console.log("run_info:", run_info['sys']);
//           HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
//                   "wd": "%E6%97%A5%E5%8E%86"
//               }, "GET").then((value) =>{
//                 console.log("sendRequest ok: ", value);
//                 run_callback(value);
//               });
//           SpStorage.set("abc", "என்ன Yogi இப்படி சொல்லிட்ட |");
//           SpStorage.set("ijk", "oh yep");
//           SpStorage.get("abc").then((value) =>{
//             console.log("SpStorage got abc promise value:", value);
//           });
//           SpStorage.get("ijk").then((value) =>{
//             console.log("SpStorage got ijk promise value:", value);
//           });
//         ''', params: 'dadada', callback: (json) {
//       logI('JsEngine-console runJsCode res: $json');
//     });
//
//     // 进行异步操作的验证
//     expect(res, isNotNull); // 验证 res 不为 null
//     expect(res, isNotEmpty); // 验证 res 不为空字符串
//     // expect(res, contains('expected value')); // 验证 res 包含某个期望的值
//   });
// }
