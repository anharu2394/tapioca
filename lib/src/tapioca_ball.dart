import "dart:typed_data";
import "dart:ui";

abstract class TapiocaBall {
  static TapiocaBall filter(Filters filter) {
    return _Filter(filter);
  }

  static TapiocaBall textOverlay(String text, int x, int y, int size, Color color) {
    return _TextOverlay(text, x, y, size, color);
  }

  static TapiocaBall imageOverlay(Uint8List bitmap, int x, int y) {
    return _ImageOverlay(bitmap, x, y);
  }

  Map<String, dynamic> toMap();
  String toTypeName();
}

enum Filters {
  pink
}

class _Filter extends TapiocaBall {
 final Filters type;
 _Filter(this.type);

 Map<String, dynamic> toMap() {
   return {'type': type.index };
 }

 String toTypeName() {
   return 'Filter';
 }
}

class _TextOverlay extends TapiocaBall {
  final String text;
  final int x;
  final int y;
  final int size;
  final Color color;
  _TextOverlay(this.text, this.x, this.y, this.size, this.color);

  Map<String, dynamic> toMap() {
    return {'text': text, 'x': x, 'y': y, 'size': size, 'color': '#${color.value.toRadixString(16).substring(2)}' };
  }

  String toTypeName() {
    return 'TextOverlay';
  }
}

class _ImageOverlay extends TapiocaBall {
  final Uint8List bitmap;
  final int x;
  final int y;
  _ImageOverlay(this.bitmap, this.x, this.y);

  Map<String, dynamic> toMap() {
    return { 'bitmap': bitmap,  'x': x, 'y': y};
  }

  String toTypeName() {
    return 'ImageOverlay';
  }
}