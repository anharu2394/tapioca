import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tapioca/src/video_editor.dart';
import 'package:tapioca/tapioca.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final navigatorKey = GlobalKey<NavigatorState>();
  File _video;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await VideoEditor.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  _pickVideo() async {

    try {
      File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
      print(video.path);
      setState(() {
        _video = video;
        isLoading = true;
      });
    } catch (error) {
      print(error);
    }
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
            child: isLoading ? CircularProgressIndicator() : RaisedButton(
          child: Text("Pick a video and Edit it"),
          color: Colors.orange,
          textColor: Colors.white,
          onPressed: () async {
            print("clicked!");
            await _pickVideo();
            var tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/result.mp4';
            print(tempDir);
            final imageBitmap =
                (await rootBundle.load("assets/tapioca_drink.png"))
                    .buffer
                    .asUint8List();
            try {
              final tapiocaBalls = [
                TapiocaBall.filter(Filters.pink),
                TapiocaBall.imageOverlay(imageBitmap, 300, 300),
                TapiocaBall.textOverlay(
                    "text", 100, 10, 100, Color(0xffffc0cb)),
              ];
              if (_video != null) {
                final cup = Cup(Content(_video.path), tapiocaBalls);
                cup.suckUp(path).then((_) async {
                  print("finished");
                  GallerySaver.saveVideo(path).then((bool success) {
                    print(success.toString());
                  });
                  navigatorKey.currentState.push(
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
          },
        )),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String path;

  VideoScreen(this.path);

  @override
  _VideoAppState createState() => _VideoAppState(path);
}

class _VideoAppState extends State<VideoScreen> {
  final String path;

  _VideoAppState(this.path);

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
