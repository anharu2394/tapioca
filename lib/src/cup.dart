import 'tapioca_ball.dart';
import 'content.dart';
import 'video_editor.dart';
class Cup {
  final Content content;
  final List<TapiocaBall> tapiocaBalls;
  Cup(this.content, this.tapiocaBalls);

  Future suckUp() {
    final Map<String, Map<String, dynamic>> processing = Map.fromIterable(tapiocaBalls, key: (v) => v.toTypeName(), value: (v) => v.toMap());
    VideoEditor.writeVideofile(content.name, processing);
  }
}