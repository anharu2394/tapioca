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
        let vidAsset = AVURLAsset(url: fileURL)
        
        // get video track
        print("aaasd")
        let videoTrack: AVAssetTrack = vidAsset.tracks(withMediaType: .video)[0]
        print("tabunn")
        let vidTimerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)
        
        guard let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
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
