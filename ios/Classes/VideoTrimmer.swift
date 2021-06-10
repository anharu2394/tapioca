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

class VideoTrimmer {
    
    typealias TrimCompletion = (Error?) -> Void
    typealias TrimPoints = [(CMTime, CMTime)]
    
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
    
    func trimVideo(startTime:Double, endTime:Double)
    {
    
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


            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4

            let startCMTime = CMTime(seconds: startTime/1000, preferredTimescale: 1000)
            let endCMTime = CMTime(seconds:endTime/1000, preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)

            exportSession.timeRange = timeRange
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
        
    }
}
