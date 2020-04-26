import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tapioca/src/video_editor.dart';
import 'package:tapioca/tapioca.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  File _video;

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
      });
    } catch(error) {
      print(error);
    }

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              RaisedButton(child: Text("pick video"),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () async {
                  print("clicked pick!");
                  _pickVideo();
                },
              ),
              RaisedButton(child: Text("click me"),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () async {
                  print("clicked!");
                  final imageBitmap = (await rootBundle.load("assets/tapioca_drink.png")).buffer.asUint8List();
                  try {
                    final tapiocaBalls = [
                      TapiocaBall.filter(Filters.pink),
                      TapiocaBall.imageOverlay(imageBitmap, 300, 300),
                      TapiocaBall.textOverlay("text",100,10,100,Color(0xffffc0cb)),
                    ];
                    if(_video != null) {
                      final cup = Cup(Content(_video.path), tapiocaBalls);
                      cup.suckUp();
                    } else {
                      print("video is null");
                    }
                  } on PlatformException {
                    print("error!!!!");
                  }
                },
              )
            ]
          ),
        ),
      ),
    );
  }
}
