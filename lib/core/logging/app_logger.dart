import 'package:flutter/foundation.dart';

class AppLogger {
  void info(String msg) => debugPrint("[INFO] $msg");
  
  void warn(String msg) => debugPrint("[WARN] $msg");
  
  void error(String msg, [Object? err, StackTrace? st]) {
    debugPrint("[ERROR] $msg");
    if (err != null) debugPrint(err.toString());
    if (st != null) debugPrint(st.toString());
  }
}


