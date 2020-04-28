import 'tapioca_ball.dart';
import 'content.dart';
import 'video_editor.dart';

/// Cup is a class to wrap a Content object and List object.
class Cup {
  /// Returns the [Content] instance for applying filters.
  final Content content;

  /// Returns the [List<TapiocaBall>] instance.
  final List<TapiocaBall> tapiocaBalls;

  /// Creates a Cup object.
  Cup(this.content, this.tapiocaBalls);

  /// Edit the video based on the [tapiocaBalls](list of processing)
  Future suckUp(String destFilePath) {
    final Map<String, Map<String, dynamic>> processing = Map.fromIterable(tapiocaBalls, key: (v) => v.toTypeName(), value: (v) => v.toMap());
    return VideoEditor.writeVideofile(content.name, destFilePath, processing);
  }
}