import 'package:flutter/foundation.dart';

class Logger {
  static void error(String module, String message, String code) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    debugPrint('[$timestamp] [$module] [ERROR] $message ($code)');
  }
}