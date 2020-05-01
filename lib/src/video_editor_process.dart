import 'package:flutter/services.dart';

class VideoEditorProcess {
  static const EventChannel _eventChannel = const EventChannel('video_editor_progress');
  static Stream receiveBroadcastStream() {
    return _eventChannel.receiveBroadcastStream();
  }
}
