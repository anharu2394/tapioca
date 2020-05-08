# Tapioca - a Flutter plugin for video editing

Tapioca is a Flutter plugin for video editing on Android and iOS.

*Note:* Feedback welcome and Pull Requests are most welcome!

## Features

- Develop for iOS and Android from a single codebase
- Edit videos(Apply filter, Overlay text and images)

## Installation

First, add `tapioca` as a [dependency in your pubspec.yaml file.](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

### iOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

- NSPhotoLibraryUsageDescription - Specifies the reason for your app to access the user’s photo library. This is called `Privacy - Photo Library Usage Description` in the visual editor.
- NSPhotoLibraryAddUsageDescription - Specifies the reason for your app to get write-only access to the user’s photo library. This is called `Privacy - Photo Library Additions Usage Description` in the visual editor.


### Android

Step 1. Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Step 2. Add the JitPack repository to your Android build file, located in `<project root>/android/build.gradle`:

```
allprojects {
	repositories {
		...
		maven { url 'https://jitpack.io' }
	}
}

```

## Usage

```dart
import 'package:tapioca/tapioca.dart';
import 'package:path_provider/path_provider.dart';

final tapiocaBalls = [
    TapiocaBall.filter(Filters.pink),
    TapiocaBall.imageOverlay(imageBitmap, 300, 300),
    TapiocaBall.textOverlay("text",100,10,100,Color(0xffffc0cb)),
];
var tempDir = await getTemporaryDirectory();
final path = '${tempDir.path}/result.mp4';
final cup = Cup(Content(videoPath), tapiocaBalls);
cup.suckUp(path).then((_) {
  print("finish processing");
});
```

### TapiocaBall

TapiocaBall is a effect to apply to the video.

|TapiocaBall|Effect|
|:-----------|:------:|
|TapiocaBall.filter(Filters filter)|Apply color filter|
|TapiocaBall.textOverlay(String text, int x, int y, int size, Color color)|Overlay text|
|TapiocaBall.imageOverlay(Uint8List bitmap, int x, int y)|Overlay images|

## Content

Content is a class to wrap a video file.

## Cup

Cup is a class to wrap a `Content` object and `List<TapiocaBall>` object.

You can edit the video by executing `.suckUp()`.


## Supported Formats

- On iOS, the backing video editor is [AVFoundation](https://developer.apple.com/documentation/avfoundation).
  please refer [here](https://developer.apple.com/documentation/avfoundation/avfiletype) for list of supported video formats.
- On Android, the backing video editor is [Mp4Composer-android](https://github.com/MasayukiSuda/Mp4Composer-android),
  The supported format is only MP4.

