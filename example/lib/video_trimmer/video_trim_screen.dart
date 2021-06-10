import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:tapioca_example/video_player_screen.dart';
import 'package:video_player/video_player.dart';

class VideoTrimScreen extends StatefulWidget {
  @override
  _VideoTrimScreenState createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  PickedFile? _video;
  bool isLoading = false;
  VideoPlayerController? _controller;
  double startPos = 0;
  double endPos = -1;

  initializeVideo() {
    if (_video == null) return;
    _controller = VideoPlayerController.file(File(_video!.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        print("output video  ==== ${_controller!.value.duration.inSeconds}");
      });
  }

  _onVideoSelectPressed() async {
    await _pickVideo();
    await initializeVideo();
  }

  _pickVideo() async {
    try {
      PickedFile? video =
          await ImagePicker().getVideo(source: ImageSource.gallery);
      if (video == null) return;
      print("videopath: ${video.path}");
      _video = video;
      isLoading = true;
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  onTrimVideoPressed() async {
    try {
      print("start time === $startPos ===  end time === $endPos");
      var tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/result.mp4';
      print("outputpath === $path");
      // await VideoEditor.onTrimVideo(_video!.path, path, startPos, endPos);
      print("outputpath after === $path");
      await VideoEditor.speed(_video!.path, path, 3);
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => VideoScreen(path)));
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: this._onVideoSelectPressed,
                icon: Icon(Icons.ondemand_video)),
            IconButton(
                onPressed: this.onTrimVideoPressed, icon: Icon(Icons.done))
          ],
        ),
        body: Center(
          child: _controller != null && _controller!.value.isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      child: TrimEditor(
                        viewerWidth: MediaQuery.of(context).size.width - 40,
                        viewerHeight: 50,
                        videoFile: _video!.path,
                        videoPlayerController: _controller!,
                        fit: BoxFit.cover,
                        onChangeEnd: (position) {
                          this.endPos = position;
                          print("onchange end ==== $position");
                        },
                        onChangeStart: (position) {
                          this.startPos = position;
                          print("onchange start ==== $position");
                        },
                        onChangePlaybackState: (state) {},
                      ),
                    )
                  ],
                )
              : CircularProgressIndicator(),
        ));
  }
}
