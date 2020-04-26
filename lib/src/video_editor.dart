import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'tapioca_ball.dart';

class VideoEditor {
  static const MethodChannel _channel =
  const MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future writeVideofile(String name, Map<String,Map<String, dynamic>> processing) async {
    await _channel.invokeMethod('writeVideofile',<String, dynamic> { 'name': name, 'processing': processing });
  }
}
