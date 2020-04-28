import 'dart:async';
import 'package:flutter/services.dart';

class VideoEditor {
  static const MethodChannel _channel =
  const MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future writeVideofile(String srcFilePath, String destFilePath, Map<String,Map<String, dynamic>> processing) async {
    await _channel.invokeMethod('writeVideofile',<String, dynamic> { 'srcFilePath': srcFilePath, 'destFilePath': destFilePath, 'processing': processing });
  }
}
