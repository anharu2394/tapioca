import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapioca/src/video_editor.dart';
import 'package:tapioca/tapioca.dart';

void main() {
  const MethodChannel channel = MethodChannel('video_editor');
  final List<MethodCall> log = <MethodCall>[];
  final fileName = 'sample.mp4';
  Directory tempDirectory;
  late String path;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp();
    path = '${tempDirectory.path}/$fileName';
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getPlatformVersion':
          return '42';
        case 'writeVideofile':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await VideoEditor.platformVersion, '42');
  });

  test('writeVideofile', () async {
    final tapiocaBalls = [
      TapiocaBall.filter(Filters.pink),
      TapiocaBall.textOverlay("text", 10, 10,100, Color(0xFFffffff)),
      TapiocaBall.imageOverlay(Uint8List(10), 10, 10),
    ];
    final cup = Cup(Content(path), tapiocaBalls);
    cup.suckUp(path);
    expect(log, <Matcher>[
      isMethodCall(
        'writeVideofile',
        arguments: <String, dynamic>{
          'srcFilePath': path,
          'destFilePath': path,
          'processing': <String, Map<String, dynamic>>{
            'Filter': {'type': '#ffc0cb' },
            'TextOverlay': {'text': 'text', 'x': 10, 'y': 10, 'size': 100, 'color': '#ffffff'},
            'ImageOverlay': { 'bitmap': Uint8List(10),'x': 10, 'y': 10,},
          },
        },
      ),
    ]);
  });
}
