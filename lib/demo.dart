import 'js_engine.dart';
import 'js_logger.dart';


/// demo
/// @Author ruilin
/// @Date 2024/4/7
///
/// @Description TODO
void main(List<String> arguments) {
  JsEngine.runCode('''
          console.log("run_params:", run_params);
          console.log("run_info:", run_info['sys']);
          // HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
          //         "wd": "%E6%97%A5%E5%8E%86"
          //     }, "GET").then((value) =>{
          //       console.log("sendRequest ok: ", value);
          //       run_callback(value);
          //     });
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


  // var json = await JsEngine.runCode('''
  //       HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
  //               "wd": "%E6%97%A5%E5%8E%86"
  //           }, "GET").then((value) =>{
  //             console.log("sendRequest ok: ", value);
  //             run_callback(value);
  //           });
  //     ''', params: 'dadada');
  // logI('JsEngine-console future runJsCode res: $json');
  // json = await JsEngine.runCode('''
  //       HttpSender.sendRequest("https://www.baidu.com/s", null, null, {
  //               "wd": "%E6%97%A5%E5%8E%86"
  //           }, "GET").then((value) =>{
  //             console.log("sendRequest ok: ", value);
  //             run_callback(value);
  //           });
  //     ''', params: 'dadada');
  // logI('JsEngine-console future runJsCode2 res: $json');
}
