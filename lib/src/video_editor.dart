import 'dart:async';

import 'package:flutter/services.dart';

class VideoEditor {
  static const MethodChannel _channel = const MethodChannel('video_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future writeVideofile(String srcFilePath, String destFilePath,
      Map<String, Map<String, dynamic>> processing,
      {int? startTime, int? endTime}) async {
    await _channel.invokeMethod('writeVideofile', <String, dynamic>{
      'srcFilePath': srcFilePath,
      'destFilePath': destFilePath,
      'processing': processing,
      'startTime': startTime,
      'endTime': endTime
    });
  }

  static Future<void> onTrimVideo(String srcFilePath, String destFilePath,
      double startTime, double endTime) async {
    await _channel.invokeMethod('trim_video', <String, dynamic>{
      'srcFilePath': srcFilePath,
      'destFilePath': destFilePath,
      'startTime': startTime.toInt(),
      'endTime': endTime.toInt()
    });
  }

  static Future<void> speed(
    String srcFilePath,
    String destFilePath,
    double speed,
  ) async {
    await _channel.invokeMethod('speed_change', <String, dynamic>{
      'srcFilePath': srcFilePath,
      'destFilePath': destFilePath,
      'speed': speed,
    });
  }
}
