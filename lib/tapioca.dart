import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'src/tapioca_ball.dart';

class VideoEditor {
  static const MethodChannel _channel =
      const MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<File> export() async {

  }
}
