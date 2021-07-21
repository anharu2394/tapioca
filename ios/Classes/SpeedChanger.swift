//
//  VideoTrimmer.swift
//  tapioca
//
//  Created by Umesh Basnet on 09/06/2021.
//

import Foundation
import AVFoundation

import AVFoundation
import Foundation
import Flutter

import UIKit
import AVFoundation

enum SpeedoMode {
    case Slower
    case Faster
}

class VSVideoSpeeder: NSObject {
    
    var sourceURL: URL
    var outputURL: URL
    var result: FlutterResult
    
    
    init(sourceFile: String, outputFile: String, result: @escaping FlutterResult) {
        self.sourceURL = URL.init(fileURLWithPath: sourceFile)
        self.outputURL = URL.init(fileURLWithPath: outputFile)
        self.result = result
    }
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        } catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    
 

    /// Range is b/w 1x, 2x and 3x. Will not happen anything if scale is out of range. Exporter will be nil in case url is invalid or unable to make asset instance.
    func scaleAsset( by scale: Int64, withMode mode: SpeedoMode) {
        
        
        guard sourceURL.isFileURL else { return }
               guard outputURL.isFileURL else { return }
              
        let manager = FileManager.default

        
        let asset = AVAsset(url: self.sourceURL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")

           
          
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                
            }catch let error {
                print(error)
            }

            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)

        
    
        /// Check the valid scale
        if scale < 1 || scale > 20 {
            /// Can not proceed, Invalid range
            self.result(nil)
            return
        }

        /// Asset

        /// Video Tracks
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count == 0 {
            /// Can not find any video track
            self.result(nil)
            return
        }

        /// Get the scaled video duration
        let scaledVideoDuration = (mode == .Faster) ? CMTimeMake(value: asset.duration.value / scale, timescale: asset.duration.timescale) : CMTimeMake(value: asset.duration.value * scale, timescale: asset.duration.timescale)
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

        /// Video track
        let videoTrack = videoTracks.first!

        let mixComposition = AVMutableComposition()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

        /// Audio Tracks
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if audioTracks.count > 0 {
            /// Use audio if video contains the audio track
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)

            /// Audio track
            let audioTrack = audioTracks.first!
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: scaledVideoDuration)
            } catch _ {
                /// Ignore audio error
            }
        }

        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: scaledVideoDuration)

            /// Keep original transformation
            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform

          
        

            
            guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(self.outputURL)")
                    self.result(nil)
                case .failed:
                    print("failed \(String(describing: exportSession.error))")
                    self.result(FlutterError(code: "video_trim_failed", message: exportSession.error?.localizedDescription, details: exportSession.error))

                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    self.result(FlutterError(code: "video_trim_cancelled", message: exportSession.error?.localizedDescription, details: exportSession.error))
                default: break
                }
            }
        

        } catch let error {
            print(error.localizedDescription)
            self.result(FlutterError(code: "video_trim_failed", message: "exportSession.error?.localizedDescriptio", details: "exportSession.error"))

            return
        }
    }

}
