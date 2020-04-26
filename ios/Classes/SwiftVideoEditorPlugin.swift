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
        guard let srcName = args["name"] as? String else {
                result(FlutterError(code: "file_name_not_found",
                                  message: "the file name is not found.",
                                  details: nil))
                return
        }
        guard let processing = args["processing"] as?  [String: [String: Any]] else {
                result(FlutterError(code: "processing_data_not_found",
                                  message: "the processing is not found.",
                                  details: nil))
                return
        }
        video.writeVideofile(srcPath: srcName,processing: processing,result: result)
        result(nil)
    default:
        result("iOS d" + UIDevice.current.systemVersion)
    }
  }
}
