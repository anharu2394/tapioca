import Flutter
import UIKit

public class SwiftVideoEditorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_editor", binaryMessenger: registrar.messenger())
    let instance = SwiftVideoEditorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "writeVideofile":
        let video = VideoGeneratorService()
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "arguments_not_found",
                            message: "the arguments is not found.",
                            details: nil))
          return
        }
        guard let srcName = args["srcFilePath"] as? String else {
                result(FlutterError(code: "src_file_path_not_found",
                                  message: "the src file path sr is not found.",
                                  details: nil))
                return
        }
        guard let destName = args["destFilePath"] as? String else {
                result(FlutterError(code: "dest_file_path_not_found",
                                  message: "the dest file path is not found.",
                                  details: nil))
                return
        }
        guard let processing = args["processing"] as?  [String: [String: Any]] else {
                result(FlutterError(code: "processing_data_not_found",
                                  message: "the processing is not found.",
                                  details: nil))
                return
        }
        video.writeVideofile(srcPath: srcName, destPath: destName, processing: processing,result: result)
    case "trim_video":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "arguments_not_found",
                            message: "the arguments is not found.",
                            details: nil))
          return
        }
        guard let srcName = args["srcFilePath"] as? String else {
                result(FlutterError(code: "src_file_path_not_found",
                                  message: "the src file path sr is not found.",
                                  details: nil))
                return
        }
        guard let destName = args["destFilePath"] as? String else {
                result(FlutterError(code: "dest_file_path_not_found",
                                  message: "the dest file path is not found.",
                                  details: nil))
                return
        }
        let startTime = args["startTime"] as? Double
        let endTime = args["endTime"] as? Double

        VideoTrimmer(sourceFile: srcName, outputFile: destName, result: result).trimVideo(startTime: startTime ?? 0, endTime: endTime ?? -1 )
        
    case "speed_change":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "arguments_not_found",
                            message: "the arguments is not found.",
                            details: nil))
          return
        }
        guard let srcName = args["srcFilePath"] as? String else {
                result(FlutterError(code: "src_file_path_not_found",
                                  message: "the src file path sr is not found.",
                                  details: nil))
                return
        }
        guard let destName = args["destFilePath"] as? String else {
                result(FlutterError(code: "dest_file_path_not_found",
                                  message: "the dest file path is not found.",
                                  details: nil))
                return
        }
        let speed = args["speed"] as? Double


        VSVideoSpeeder(sourceFile: srcName, outputFile: destName, result: result).scaleAsset(by: 5, withMode: SpeedoMode.Faster)
    default:
        result("iOS d" + UIDevice.current.systemVersion)
    }
  }
}
