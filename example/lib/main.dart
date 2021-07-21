import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as IMG;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:tapioca_example/video_player_screen.dart';
import 'package:tapioca_example/video_trimmer/video_trim_screen.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final navigatorKey = GlobalKey<NavigatorState>();
  PickedFile? _video = PickedFile(
      "/data/user/0/me.anharu.video_editor_example/cache/image_picker6730465733272534646.mp4");
  bool isLoading = false;
  GlobalKey textKey = GlobalKey();
  GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  _pickVideo() async {
    try {
      PickedFile? video =
          await ImagePicker().getVideo(source: ImageSource.gallery);
      if (video == null) return;
      print("videopath: ${video.path}");
      setState(() {
        _video = video;
        isLoading = true;
      });
    } catch (error) {
      print(error);
    }
  }

  void _processVideo() async {
    try {
      print("clicked!");
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => VideoScreen(_video!.path)));
      return;
      // await _pickVideo();
      var tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/result.mp4';
      print(tempDir);
      final imageBitmap = await getImage();
      try {
        final tapiocaBalls = [
          TapiocaBall.imageOverlay(imageBitmap!, 50, 50),
        ];
        if (_video != null) {
          final cup = Cup(Content(_video!.path), tapiocaBalls);
          cup.suckUp(path, startTime: 400, endTime: 10000).then((_) async {
            print("finished");
            GallerySaver.saveVideo(path);
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (context) => VideoScreen(path)),
            );
            setState(() {
              isLoading = false;
            });
          });
        } else {
          print("video is null");
        }
      } on PlatformException {
        print("error!!!!");
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Uint8List?> getImage() async {
    print("getImage called");
    print(
        "getImage called boundary ${_repaintBoundaryKey.currentContext?.findRenderObject() is RenderRepaintBoundary} ");
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    print("getImage called boundary $boundary ");

    ui.Image image = await boundary.toImage(pixelRatio: 5);
    print("getImage called image $image ");
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    print("getImage called bytedata $byteData ");
    return byteData!.buffer.asUint8List();
    // RenderBox renderObject =
    //     textKey.currentContext?.findRenderObject() as RenderBox;
    //
    // print("image size ==== ${renderObject.size}");
    //
    // return resizeImage(
    //     byteData!.buffer.asUint8List(), renderObject.size.width.toInt());
  }

  Future<Uint8List> resizeImage(Uint8List data, int width) async {
    IMG.Image? img = IMG.decodeImage(data);
    print("before resize ==== ${img?.width} === ${img?.height}");
    IMG.Image resized = IMG.copyResize(img!, width: width);
    print("before resize ==== ${resized.width} === ${resized.height}");
    var a = Uint8List.fromList(IMG.encodePng(resized));
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Text(
                          "Hello how are you",
                          key: textKey,
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        ),
                      ),
                      RaisedButton(
                        child: Text("Pick a video and Edit it"),
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: _processVideo,
                      ),
                      ElevatedButton(onPressed: (){
                        navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (_) => VideoTrimScreen()));
                      }, child: Text("Trim video"))
                    ],
                  )),
      ),
    );
  }
}

