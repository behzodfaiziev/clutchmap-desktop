import 'package:flutter/foundation.dart';

abstract class Telemetry {
  void track(String event, {Map<String, dynamic>? props});
}

class ConsoleTelemetry implements Telemetry {
  @override
  void track(String event, {Map<String, dynamic>? props}) {
    debugPrint("[EVENT] $event props=$props");
  }
}


