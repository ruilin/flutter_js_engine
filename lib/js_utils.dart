import 'dart:math';

/// js_utils
/// @Author ruilin
/// @Date 2024/4/17
///
/// @Description TODO
class JsUtils {

  static String generateRandomId(int length) {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    String result = '';
    for (int i = 0; i < length; i++) {
      result += characters[random.nextInt(charactersLength)];
    }
    return result;
  }
}