import Foundation
import AVFoundation
import Photos
import Flutter

public protocol VideoGeneratorServiceInterface {
  func writeVideofile(srcPath:String, destPath:String, processing: [String: [String:Any]], result: @escaping FlutterResult)
}

public class VideoGeneratorService: VideoGeneratorServiceInterface {
  public func writeVideofile(srcPath:String, destPath:String, processing: [String: [String:Any]], result: @escaping FlutterResult) {
    let fileURL = URL(fileURLWithPath: srcPath)

    let composition = AVMutableComposition()
    var vidAsset = AVURLAsset(url: fileURL, options: nil)

    // get video track
    let vtrack =  vidAsset.tracks(withMediaType: AVMediaType.video)
    print("eee")
    guard let videoTrack:AVAssetTrack = vtrack[0] else {
      print("not found track")
      result(FlutterError(code: "video_processing_failed",
        message: "video track is not found.",
        details: nil))
      return
    }
    print("tabunn")
    let vidDuration = videoTrack.timeRange.duration
    let vidTimerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)

    var error: NSError?
    guard let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
      result(FlutterError(code: "video_processing_failed",
        message: "video processing is failed.",
        details: nil))
      return
    }
    do {
      try compositionvideoTrack.insertTimeRange(vidTimerange, of: videoTrack, at: CMTime.zero)
      if let audioAssetTrack = vidAsset.tracks(withMediaType: .audio).first,
      let compositionAudioTrack = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: kCMPersistentTrackID_Invalid) {
        try compositionAudioTrack.insertTimeRange(
          vidTimerange,
          of: audioAssetTrack,
          at: .zero)
      }
      } catch {
        print(error)
        result(FlutterError(code: "video_processing_failed",
          message: "video processing is failed.",
          details: nil))
        return
      }

      compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
      let size = videoTrack.naturalSize
      var filters  = [CALayer]()
      for (key, value) in processing  {
        switch key {
          case "Filter":
          guard let type = value["type"] as? String else {
            print("not found value")
            result(FlutterError(code: "processing_data_invalid",
              message: "one Filter member is not found.",
              details: nil))
            return
          }
          let filter = Filter(type: type)
          let layer = CALayer()
          layer.backgroundColor = UIColor(hex:filter.type.replacingOccurrences(of: "#", with: "")).cgColor
          layer.opacity = 0.5
          layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
          filters.append(layer)

          case "TextOverlay":
          guard let text = value["text"] as? String,
          let x = value["x"] as? NSNumber,
          let y = value["y"] as? NSNumber,
          let textSize = value["size"] as? NSNumber,
          let color = value["color"] as? String else {
            print("not found text overlay")
            result(FlutterError(code: "processing_data_invalid",
              message: "one TextOverlay member is not found.",
              details: nil))
            return
          }
          let textOverlay = TextOverlay(text: text, x: x, y: y, size: textSize, color: color)
          let titleLayer = CALayer()
          let uiImage = imageWith(name: textOverlay.text, width: size.width, height: size.width, size: textOverlay.size.intValue, color: UIColor(hex:textOverlay.color.replacingOccurrences(of: "#", with: "")))
          titleLayer.contents = uiImage?.cgImage
          print(uiImage?.size)
          titleLayer.frame = CGRect(x: CGFloat(textOverlay.x.intValue), y: size.height - CGFloat(textOverlay.y.intValue) - uiImage!.size.height,
            width: uiImage!.size.width, height: uiImage!.size.height)
          filters.append(titleLayer)
          case "ImageOverlay":
          guard let bitmap = value["bitmap"] as? FlutterStandardTypedData,
          let x = value["x"] as? NSNumber,
          let y = value["y"] as? NSNumber else {
            print("not found image overlay")
            result(FlutterError(code: "processing_data_invalid",
              message: "one ImageOverlay member is not found.",
              details: nil))
            return
          }
          let imageOverlay = ImageOverlay(bitmap: bitmap.data, x: x, y: y)
          let datos: Data = imageOverlay.bitmap
          let image = UIImage(data: datos)
          let imglayer = CALayer()
          imglayer.contents = image?.cgImage
          guard let imageWidth: CGFloat = image?.size.width else {
            result(FlutterError(code: "video_processing_failed",
              message: "video processing is failed.",
              details: nil))
            return
          }
          guard let imageHeight: CGFloat = image?.size.height else {
            result(FlutterError(code: "video_processing_failed",
              message: "video processing is failed.",
              details: nil))
            return
          }
          imglayer.frame = CGRect(x:CGFloat(imageOverlay.x.intValue), y: size.height - CGFloat(imageOverlay.y.intValue) - imageHeight, width: imageWidth, height: imageHeight)
          imglayer.opacity = 1
          filters.append(imglayer)
          default:
          print("Not implement filter name")
        }
      }
      let videolayer = CALayer()
      videolayer.frame = CGRect(x:0,y:0, width: size.width, height: size.height)
      let parentlayer = CALayer()
      parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      parentlayer.addSublayer(videolayer)
      for item in filters {
        parentlayer.addSublayer(item)
      }
      let layercomposition = AVMutableVideoComposition()
      layercomposition.frameDuration = CMTime(value: 1, timescale:30)
      layercomposition.renderSize = size
      layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)

      let instruction = AVMutableVideoCompositionInstruction()
      instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
      let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionvideoTrack)
      instruction.layerInstructions = [layerinstruction]
      layercomposition.instructions = [instruction]

      let movieFilePath = destPath
      let movieDestinationUrl = URL(fileURLWithPath: movieFilePath)
      print(movieDestinationUrl)
      guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality) else {
        print("assertExport error")
        result(FlutterError(code: "video_processing_failed",
          message: "video processing is failed.",
          details: nil))
        return
      }
      assetExport.outputFileType = AVFileType.mp4
      assetExport.videoComposition = layercomposition

      do { // delete old video
        try FileManager.default.removeItem(at: movieDestinationUrl)
        } catch {
        }

        assetExport.outputURL = movieDestinationUrl
        assetExport.exportAsynchronously(completionHandler:{
         switch assetExport.status{
           case  AVAssetExportSessionStatus.failed:
           print("failed \(assetExport.error)")
           case AVAssetExportSessionStatus.cancelled:
           print("cancelled \(assetExport.error)")
           default:
           print("Movie complete")
           result(nil)

         }
         })
      }
      private func imageWith(name: String, width: CGFloat, height: CGFloat, size: Int, color: UIColor) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: width, height: CGFloat(size))
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .left
        nameLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        nameLabel.textColor = color
        nameLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(size))
        nameLabel.text = name
        nameLabel.numberOfLines = 0
        nameLabel.sizeToFit()
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
         nameLabel.layer.render(in: currentContext)
         let nameImage = UIGraphicsGetImageFromCurrentImageContext()
         return nameImage
       }
       return nil
     }
   }

   extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
      let v = Int("000000" + hex, radix: 16) ?? 0
      let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
      let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
      let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
      self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
  }

  struct Filter {
    let type: String

  }

  struct ImageOverlay {
    let bitmap: Data
    let x: NSNumber
    let y: NSNumber
  }

  struct TextOverlay {
    let text: String
    let x: NSNumber
    let y: NSNumber
    let size: NSNumber
    let color: String
  }
