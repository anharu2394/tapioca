import 'dart:async';

import 'package:flutter/services.dart';

class VideoEditor {
  static const MethodChannel _channel =
      const MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
